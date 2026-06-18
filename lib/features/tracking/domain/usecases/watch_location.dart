import '../entities/location_point.dart';
import '../repositories/tracking_repository.dart';

class WatchLocationParams {
  final Duration interval;

  const WatchLocationParams({
    this.interval = const Duration(seconds: 5),
  });
}

class WatchLocation {
  final TrackingRepository repository;

  const WatchLocation(this.repository);

  Stream<LocationPoint> call(WatchLocationParams params) =>
      repository.watchLocation(interval: params.interval);
}
