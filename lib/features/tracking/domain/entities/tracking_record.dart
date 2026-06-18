import 'package:equatable/equatable.dart';
import 'distance.dart';

class TrackingRecord extends Equatable {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final Distance distance;

  const TrackingRecord({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  @override
  List<Object?> get props => [timestamp, latitude, longitude, distance];
}
