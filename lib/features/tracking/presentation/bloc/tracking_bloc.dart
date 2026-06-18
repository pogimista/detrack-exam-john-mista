import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/get_target.dart';
import '../../domain/usecases/watch_location.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final GetTarget getTarget;
  final WatchLocation watchLocation;

  StreamSubscription? _locationSubscription;

  TrackingBloc({
    required this.getTarget,
    required this.watchLocation,
  }) : super(const TrackingIdle()) {
    on<StartTrackingRequested>(_onStartTrackingRequested);
    on<StopTrackingRequested>(_onStopTrackingRequested);
    on<LocationUpdated>(_onLocationUpdated);
    on<TrackingFailed>(_onTrackingFailed);
  }

  Future<void> _onStartTrackingRequested(
    StartTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingStarting());

    final result = await getTarget(const NoParams());
    switch (result) {
      case Success(data: final target):
        emit(TrackingInProgress(target: target));
        await _locationSubscription?.cancel();
        _locationSubscription = watchLocation(
          const WatchLocationParams(interval: Duration(seconds: 5)),
        ).listen(
          (point) => add(LocationUpdated(point)),
          onError: (error) => add(TrackingFailed(error.toString())),
        );
      case Err(failure: final failure):
        emit(TrackingFailure(failure.message));
    }
  }

  Future<void> _onStopTrackingRequested(
    StopTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    emit(const TrackingIdle());
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<TrackingState> emit,
  ) {
    final current = state;
    if (current is TrackingInProgress) {
      emit(current.copyWith(lastLocation: event.point));
    }
  }

  void _onTrackingFailed(
    TrackingFailed event,
    Emitter<TrackingState> emit,
  ) {
    emit(TrackingFailure(event.message));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
