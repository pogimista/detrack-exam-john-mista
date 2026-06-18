import 'package:equatable/equatable.dart';
import '../../domain/entities/distance.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/target.dart';
import '../../domain/entities/tracking_record.dart';

sealed class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingIdle extends TrackingState {
  const TrackingIdle();
}

class TrackingStarting extends TrackingState {
  const TrackingStarting();
}

class TrackingInProgress extends TrackingState {
  final Target target;
  final LocationPoint? lastLocation;
  final Distance? distance;
  final List<TrackingRecord> records;

  const TrackingInProgress({
    required this.target,
    this.lastLocation,
    this.distance,
    this.records = const [],
  });

  TrackingInProgress copyWith({
    LocationPoint? lastLocation,
    Distance? distance,
    List<TrackingRecord>? records,
  }) {
    return TrackingInProgress(
      target: target,
      lastLocation: lastLocation ?? this.lastLocation,
      distance: distance ?? this.distance,
      records: records ?? this.records,
    );
  }

  @override
  List<Object?> get props => [target, lastLocation, distance, records];
}

class TrackingFailure extends TrackingState {
  final String message;

  const TrackingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
