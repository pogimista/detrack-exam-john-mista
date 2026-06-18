import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/target.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/location_data_source.dart';
import '../datasources/tracking_remote_data_source.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource remoteDataSource;
  final LocationDataSource locationDataSource;

  const TrackingRepositoryImpl({
    required this.remoteDataSource,
    required this.locationDataSource,
  });

  @override
  Future<Result<Target>> fetchTarget() async {
    try {
      final target = await remoteDataSource.fetchTarget();
      return Success(target);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } on DioException catch (e) {
      return Err(NetworkFailure(e.message ?? 'Network error'));
    }
  }

  @override
  Stream<LocationPoint> watchLocation({required Duration interval}) {
    return locationDataSource.watchLocation(interval: interval);
  }
}
