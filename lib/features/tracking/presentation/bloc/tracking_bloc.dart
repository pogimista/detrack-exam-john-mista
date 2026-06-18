import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/usecases/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/tracking_record.dart';
import '../../domain/usecases/calculate_distance.dart';
import '../../domain/usecases/clear_tracking_records.dart';
import '../../domain/usecases/get_target.dart';
import '../../domain/usecases/get_tracking_records.dart';
import '../../domain/usecases/save_tracking_record.dart';
import '../../domain/usecases/watch_location.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final GetTarget getTarget;
  final WatchLocation watchLocation;
  final CalculateDistance calculateDistance;
  final SaveTrackingRecord saveTrackingRecord;
  final GetTrackingRecords getTrackingRecords;
  final ClearTrackingRecords clearTrackingRecords;

  StreamSubscription? _locationSubscription;

  TrackingBloc({
    required this.getTarget,
    required this.watchLocation,
    required this.calculateDistance,
    required this.saveTrackingRecord,
    required this.getTrackingRecords,
    required this.clearTrackingRecords,
  }) : super(const TrackingIdle()) {
    on<StartTrackingRequested>(_onStartTrackingRequested);
    on<StopTrackingRequested>(_onStopTrackingRequested);
    on<LocationUpdated>(_onLocationUpdated);
    on<TrackingFailed>(_onTrackingFailed);
    on<ClearRecordsRequested>(_onClearRecordsRequested);
  }

  Future<void> _onStartTrackingRequested(
    StartTrackingRequested event,
    Emitter<TrackingState> emit,
  ) async {
    // Guards against a second StartTrackingRequested (e.g. a fast double
    // tap) racing this handler before the first await suspends — on<Event>
    // processes events concurrently by default, so without this check both
    // invocations would create their own location stream, doubling reads.
    if (state is TrackingStarting || state is TrackingInProgress) return;

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

  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<TrackingState> emit,
  ) async {
    final current = state;
    if (current is! TrackingInProgress) return;

    final distance = calculateDistance(
      CalculateDistanceParams(from: event.point, to: current.target),
    );

    await saveTrackingRecord(
      TrackingRecord(
        timestamp: event.point.timestamp,
        latitude: event.point.latitude,
        longitude: event.point.longitude,
        distance: distance,
      ),
    );

    var records = current.records;
    final recordsResult = await getTrackingRecords(const NoParams());
    if (recordsResult is Success<List<TrackingRecord>>) {
      records = recordsResult.data.reversed.toList();
    }

    emit(
      current.copyWith(
        lastLocation: event.point,
        distance: distance,
        records: records,
      ),
    );
  }

  void _onTrackingFailed(
    TrackingFailed event,
    Emitter<TrackingState> emit,
  ) {
    emit(TrackingFailure(event.message));
  }

  Future<void> _onClearRecordsRequested(
    ClearRecordsRequested event,
    Emitter<TrackingState> emit,
  ) async {
    await clearTrackingRecords(const NoParams());

    final current = state;
    if (current is TrackingInProgress) {
      emit(current.copyWith(records: const []));
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
