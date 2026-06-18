import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/location_point.dart';

abstract interface class LocationDataSource {
  Stream<LocationPoint> watchLocation({required Duration interval});
}

class LocationDataSourceImpl implements LocationDataSource {
  Future<void> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const ServerException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const ServerException('Location permission denied.');
    }
  }

  @override
  Stream<LocationPoint> watchLocation({required Duration interval}) {
    late StreamController<LocationPoint> controller;
    Timer? timer;

    Future<void> tick() async {
      final position = await Geolocator.getCurrentPosition();
      controller.add(
        LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        ),
      );
    }

    controller = StreamController<LocationPoint>(
      onListen: () async {
        try {
          await _ensurePermission();
          await tick();
          timer = Timer.periodic(interval, (_) => tick());
        } catch (e) {
          controller.addError(e);
        }
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }
}
