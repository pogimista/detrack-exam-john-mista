import '../../../../core/utils/result.dart';
import '../entities/location_point.dart';
import '../entities/target.dart';

abstract interface class TrackingRepository {
  Future<Result<Target>> fetchTarget();

  Stream<LocationPoint> watchLocation({required Duration interval});
}
