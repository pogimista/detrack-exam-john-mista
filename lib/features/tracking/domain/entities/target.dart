import 'package:equatable/equatable.dart';

class Target extends Equatable {
  final String id;
  final double targetLat;
  final double targetLng;

  const Target({
    required this.id,
    required this.targetLat,
    required this.targetLng,
  });

  @override
  List<Object?> get props => [id, targetLat, targetLng];
}
