import 'package:equatable/equatable.dart';

class Distance extends Equatable {
  final double meters;

  const Distance(this.meters);

  double get kilometers => meters / 1000;

  String get formatted => meters < 1000
      ? '${meters.toStringAsFixed(1)} m'
      : '${kilometers.toStringAsFixed(2)} km';

  @override
  List<Object?> get props => [meters];
}
