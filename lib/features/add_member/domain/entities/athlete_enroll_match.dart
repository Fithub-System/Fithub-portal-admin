import 'package:equatable/equatable.dart';

/// Athlete match from `find_athlete_for_enroll` (FEAT-13).
class AthleteEnrollMatch extends Equatable {
  const AthleteEnrollMatch({
    required this.id,
    required this.fullName,
  });

  final String id;
  final String fullName;

  @override
  List<Object?> get props => [id, fullName];
}
