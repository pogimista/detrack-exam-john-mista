import '../../domain/entities/distance.dart';
import '../../domain/entities/tracking_record.dart';

class TrackingRecordModel extends TrackingRecord {
  const TrackingRecordModel({
    required super.timestamp,
    required super.latitude,
    required super.longitude,
    required super.distance,
  });

  factory TrackingRecordModel.fromEntity(TrackingRecord record) =>
      TrackingRecordModel(
        timestamp: record.timestamp,
        latitude: record.latitude,
        longitude: record.longitude,
        distance: record.distance,
      );

  factory TrackingRecordModel.fromMap(Map<dynamic, dynamic> map) =>
      TrackingRecordModel(
        timestamp: DateTime.parse(map['timestamp'] as String),
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        distance: Distance((map['distance'] as num).toDouble()),
      );

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance.meters,
      };
}
