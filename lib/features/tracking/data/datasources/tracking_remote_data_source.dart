import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/target_model.dart';

abstract interface class TrackingRemoteDataSource {
  Future<TargetModel> fetchTarget();
}

/// Backend endpoint path for the mock target payload.
/// A [MockTargetInterceptor] resolves requests to this path locally,
/// without hitting the network, simulating a real backend response.
const String targetEndpointPath = '/targets/current';

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final Dio dio;

  const TrackingRemoteDataSourceImpl(this.dio);

  @override
  Future<TargetModel> fetchTarget() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(targetEndpointPath);
      return TargetModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch target');
    }
  }
}
