import 'package:equatable/equatable.dart';

/// Live gym capacity snapshot from `public.gyms` (or Drift cache).
class GymOccupancy extends Equatable {
  const GymOccupancy({
    required this.id,
    required this.name,
    required this.currentOccupancy,
    required this.capacityLimit,
  });

  final String id;
  final String name;
  final int currentOccupancy;
  final int capacityLimit;

  double get progress {
    if (capacityLimit <= 0) return 0;
    return (currentOccupancy / capacityLimit).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [id, name, currentOccupancy, capacityLimit];
}
