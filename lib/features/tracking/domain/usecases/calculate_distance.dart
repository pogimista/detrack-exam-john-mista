import 'dart:math';
import '../entities/distance.dart';
import '../entities/location_point.dart';
import '../entities/target.dart';

class CalculateDistanceParams {
  final LocationPoint from;
  final Target to;

  const CalculateDistanceParams({required this.from, required this.to});
}

/// Computes the great-circle distance between a location reading and the
/// target coordinates using the Haversine formula.
class CalculateDistance {
  static const double _earthRadiusMeters = 6371000;

  Distance call(CalculateDistanceParams params) {
    final lat1 = _toRadians(params.from.latitude);
    final lat2 = _toRadians(params.to.targetLat);
    final dLat = _toRadians(params.to.targetLat - params.from.latitude);
    final dLng = _toRadians(params.to.targetLng - params.from.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return Distance(_earthRadiusMeters * c);
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
