import 'package:equatable/equatable.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/target.dart';

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

  const TrackingInProgress({
    required this.target,
    this.lastLocation,
  });

  TrackingInProgress copyWith({LocationPoint? lastLocation}) {
    return TrackingInProgress(
      target: target,
      lastLocation: lastLocation ?? this.lastLocation,
    );
  }

  @override
  List<Object?> get props => [target, lastLocation];
}

class TrackingFailure extends TrackingState {
  final String message;

  const TrackingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
