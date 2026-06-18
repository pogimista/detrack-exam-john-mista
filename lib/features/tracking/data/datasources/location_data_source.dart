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
    var cancelled = false;

    Future<void> tick() async {
      try {
        final position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 10),
        );
        if (!cancelled) {
          controller.add(
            LocationPoint(
              latitude: position.latitude,
              longitude: position.longitude,
              timestamp: DateTime.now(),
            ),
          );
        }
      } catch (e) {
        if (!cancelled) controller.addError(e);
      }
    }

    // Schedules the next fetch only after the current one settles, so a
    // slow GPS fix (e.g. on emulators or indoors) can never overlap with
    // the following tick and produce duplicate readings.
    Future<void> scheduleNext() async {
      while (!cancelled) {
        await Future.delayed(interval);
        if (cancelled) return;
        await tick();
      }
    }

    controller = StreamController<LocationPoint>(
      onListen: () async {
        try {
          await _ensurePermission();
          await tick();
          scheduleNext();
        } catch (e) {
          controller.addError(e);
        }
      },
      onCancel: () {
        cancelled = true;
      },
    );

    return controller.stream;
  }
}
