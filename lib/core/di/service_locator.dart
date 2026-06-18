import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../network/mock_target_interceptor.dart';
import '../../features/tracking/data/datasources/location_data_source.dart';
import '../../features/tracking/data/datasources/tracking_record_local_data_source.dart';
import '../../features/tracking/data/datasources/tracking_remote_data_source.dart';
import '../../features/tracking/data/repositories/tracking_record_repository_impl.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/repositories/tracking_record_repository.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/usecases/calculate_distance.dart';
import '../../features/tracking/domain/usecases/get_target.dart';
import '../../features/tracking/domain/usecases/get_tracking_records.dart';
import '../../features/tracking/domain/usecases/save_tracking_record.dart';
import '../../features/tracking/domain/usecases/watch_location.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';

const String trackingRecordsBoxName = 'tracking_records_box';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<AppConfig>(AppConfig.instance);
  sl.registerSingleton<Dio>(Dio()..interceptors.add(MockTargetInterceptor()));
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  sl.registerSingleton<Box<Map>>(
    await Hive.openBox<Map>(trackingRecordsBoxName),
  );

  // Tracking feature
  sl.registerLazySingleton<TrackingRemoteDataSource>(
    () => TrackingRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(),
  );
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      remoteDataSource: sl<TrackingRemoteDataSource>(),
      locationDataSource: sl<LocationDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetTarget>(() => GetTarget(sl<TrackingRepository>()));
  sl.registerLazySingleton<WatchLocation>(
    () => WatchLocation(sl<TrackingRepository>()),
  );
  sl.registerLazySingleton<CalculateDistance>(() => CalculateDistance());

  sl.registerLazySingleton<TrackingRecordLocalDataSource>(
    () => TrackingRecordLocalDataSourceImpl(sl<Box<Map>>()),
  );
  sl.registerLazySingleton<TrackingRecordRepository>(
    () => TrackingRecordRepositoryImpl(sl<TrackingRecordLocalDataSource>()),
  );
  sl.registerLazySingleton<SaveTrackingRecord>(
    () => SaveTrackingRecord(sl<TrackingRecordRepository>()),
  );
  sl.registerLazySingleton<GetTrackingRecords>(
    () => GetTrackingRecords(sl<TrackingRecordRepository>()),
  );

  sl.registerFactory<TrackingBloc>(
    () => TrackingBloc(
      getTarget: sl<GetTarget>(),
      watchLocation: sl<WatchLocation>(),
      calculateDistance: sl<CalculateDistance>(),
      saveTrackingRecord: sl<SaveTrackingRecord>(),
      getTrackingRecords: sl<GetTrackingRecords>(),
    ),
  );
}
