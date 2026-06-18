import 'package:dio/dio.dart';
import '../../features/tracking/data/datasources/tracking_remote_data_source.dart';

/// Simulates a backend endpoint that returns mock target data,
/// so the app can be developed/tested without a real server.
class MockTargetInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == targetEndpointPath) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: const {
            'id': '001',
            'target_lat': 1.265,
            'target_lng': 103.695,
          },
        ),
      );
      return;
    }
    handler.next(options);
  }
}
