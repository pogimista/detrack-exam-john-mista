import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../network/mock_target_interceptor.dart';
import '../../features/tracking/data/datasources/location_data_source.dart';
import '../../features/tracking/data/datasources/tracking_remote_data_source.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/usecases/get_target.dart';
import '../../features/tracking/domain/usecases/watch_location.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<AppConfig>(AppConfig.instance);
  sl.registerSingleton<Dio>(Dio()..interceptors.add(MockTargetInterceptor()));
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
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
  sl.registerFactory<TrackingBloc>(
    () => TrackingBloc(
      getTarget: sl<GetTarget>(),
      watchLocation: sl<WatchLocation>(),
    ),
  );
}
