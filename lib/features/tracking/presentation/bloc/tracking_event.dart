import 'package:equatable/equatable.dart';
import '../../domain/entities/location_point.dart';

sealed class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTrackingRequested extends TrackingEvent {
  const StartTrackingRequested();
}

class StopTrackingRequested extends TrackingEvent {
  const StopTrackingRequested();
}

class LocationUpdated extends TrackingEvent {
  final LocationPoint point;

  const LocationUpdated(this.point);

  @override
  List<Object?> get props => [point];
}

class TrackingFailed extends TrackingEvent {
  final String message;
  final bool permanentlyDenied;

  const TrackingFailed(this.message, {this.permanentlyDenied = false});

  @override
  List<Object?> get props => [message, permanentlyDenied];
}

class ClearRecordsRequested extends TrackingEvent {
  const ClearRecordsRequested();
}

class LoadStoredRecordsRequested extends TrackingEvent {
  const LoadStoredRecordsRequested();
}
