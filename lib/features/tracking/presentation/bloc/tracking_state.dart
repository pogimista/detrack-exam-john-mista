import 'package:equatable/equatable.dart';
import '../../domain/entities/distance.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/target.dart';
import '../../domain/entities/tracking_record.dart';

sealed class TrackingState extends Equatable {
  final List<TrackingRecord> records;

  const TrackingState({this.records = const []});

  @override
  List<Object?> get props => [records];
}

class TrackingIdle extends TrackingState {
  const TrackingIdle({super.records});
}

class TrackingStarting extends TrackingState {
  const TrackingStarting({super.records});
}

class TrackingInProgress extends TrackingState {
  final Target target;
  final LocationPoint? lastLocation;
  final Distance? distance;

  const TrackingInProgress({
    required this.target,
    this.lastLocation,
    this.distance,
    super.records,
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
  final bool permanentlyDenied;

  const TrackingFailure(
    this.message, {
    this.permanentlyDenied = false,
    super.records,
  });

  @override
  List<Object?> get props => [message, permanentlyDenied, records];
}
