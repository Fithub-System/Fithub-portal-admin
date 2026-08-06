import 'package:equatable/equatable.dart';

/// Stitch Class Manager attendee chrome fixtures (FEAT-18 — no booking Backend).
abstract final class ClassManagerStitchFixtures {
  static const List<ClassAttendeeFixture> attendees = [
    ClassAttendeeFixture(
      name: 'Alex Rivera',
      subtitle: 'Member since 2021',
      present: true,
    ),
    ClassAttendeeFixture(
      name: 'Jordan Smith',
      subtitle: 'Pro Tier',
      present: true,
    ),
    ClassAttendeeFixture(
      name: 'Taylor Hayes',
      subtitle: 'Waiting Arrival',
      present: false,
    ),
    ClassAttendeeFixture(
      name: 'Morgan Chen',
      subtitle: 'Elite Tier',
      present: true,
    ),
    ClassAttendeeFixture(
      name: 'Riley Brooks',
      subtitle: 'New Member',
      present: true,
    ),
  ];

  /// Fixture capacity fraction matching Stitch Power HIIT chrome.
  static const int fixtureBooked = 21;
  static const int fixtureCapacity = 25;
}

class ClassAttendeeFixture extends Equatable {
  const ClassAttendeeFixture({
    required this.name,
    required this.subtitle,
    required this.present,
  });

  final String name;
  final String subtitle;
  final bool present;

  @override
  List<Object?> get props => [name, subtitle, present];
}
