import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}
