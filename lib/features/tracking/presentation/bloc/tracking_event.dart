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

  const TrackingFailed(this.message);

  @override
  List<Object?> get props => [message];
}
