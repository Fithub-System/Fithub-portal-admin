import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/class_session.dart';
import '../screens/class_manager_screen.dart';

/// Weekly schedule grid — Stitch Class Manager (8-col: time + Mon–Sun).
class ClassWeeklyScheduleGrid extends StatelessWidget {
  const ClassWeeklyScheduleGrid({
    super.key,
    required this.canWrite,
    required this.weekStart,
    required this.sessions,
    required this.coaches,
    required this.selectedSessionId,
    required this.onSelect,
    required this.onScheduleSlot,
  });

  final bool canWrite;
  final DateTime weekStart;
  final List<ClassSession> sessions;
  final List<ClassCoachOption> coaches;
  final String? selectedSessionId;
  final ValueChanged<ClassSession?> onSelect;
  final ValueChanged<DateTime> onScheduleSlot;

  static const int _startHour = 6;
  static const int _endHour = 12;
  static const double _rowHeight = 96;
  static const double _headerHeight = 64;

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(
      _endHour - _startHour + 1,
      (i) => _startHour + i,
    );
    final days = List<DateTime>.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: KineticTokens.zincGray.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: _headerHeight,
            child: Row(
              children: [
                _HeaderCell(
                  child: Text(
                    'classes.manager.time'.tr().toUpperCase(),
                    style: _headerStyle,
                  ),
                ),
                for (final day in days)
                  Expanded(
                    child: _HeaderCell(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE', context.locale.toString())
                                .format(day)
                                .toUpperCase(),
                            style: _headerStyle,
                          ),
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                              color: KineticTokens.pureWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (final hour in hours)
            SizedBox(
              height: _rowHeight,
              child: Row(
                children: [
                  _HeaderCell(
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: _headerStyle,
                    ),
                  ),
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: _DayHourCell(
                        canWrite: canWrite,
                        day: days[d],
                        hour: hour,
                        sessions: sessions,
                        coaches: coaches,
                        selectedSessionId: selectedSessionId,
                        onSelect: onSelect,
                        onScheduleSlot: onScheduleSlot,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    color: Color(0xFFC4C9AC),
  );
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: KineticTokens.zincGray.withValues(alpha: 0.15),
          ),
          bottom: BorderSide(
            color: KineticTokens.zincGray.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: child,
    );
  }
}

class _DayHourCell extends StatelessWidget {
  const _DayHourCell({
    required this.canWrite,
    required this.day,
    required this.hour,
    required this.sessions,
    required this.coaches,
    required this.selectedSessionId,
    required this.onSelect,
    required this.onScheduleSlot,
  });

  final bool canWrite;
  final DateTime day;
  final int hour;
  final List<ClassSession> sessions;
  final List<ClassCoachOption> coaches;
  final String? selectedSessionId;
  final ValueChanged<ClassSession?> onSelect;
  final ValueChanged<DateTime> onScheduleSlot;

  @override
  Widget build(BuildContext context) {
    final slotStart = DateTime(day.year, day.month, day.day, hour);
    final matches = sessions.where((s) {
      if (s.isCancelled) return false;
      return s.startsAt.year == day.year &&
          s.startsAt.month == day.month &&
          s.startsAt.day == day.day &&
          s.startsAt.hour == hour;
    }).toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: KineticTokens.zincGray.withValues(alpha: 0.12),
          ),
          bottom: BorderSide(
            color: KineticTokens.zincGray.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: matches.isEmpty
          ? _EmptySlot(
              canWrite: canWrite,
              showScheduleNewChrome:
                  sessions.isEmpty && hour == 9 && day.weekday == DateTime.wednesday,
              onSchedule: () => onScheduleSlot(slotStart),
            )
          : Padding(
              padding: const EdgeInsetsDirectional.all(4),
              child: Column(
                children: [
                  for (final session in matches)
                    Expanded(
                      child: _SessionCard(
                        session: session,
                        coachLabel: coachLabelFor(
                          coaches,
                          session.coachEmployeeId,
                        ),
                        selected: session.id == selectedSessionId,
                        onTap: () => onSelect(session),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({
    required this.canWrite,
    required this.showScheduleNewChrome,
    required this.onSchedule,
  });

  final bool canWrite;
  final bool showScheduleNewChrome;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    if (!canWrite) {
      return const SizedBox.expand();
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSchedule,
        child: Center(
          child: showScheduleNewChrome
              ? Container(
                  margin: const EdgeInsetsDirectional.all(6),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: KineticTokens.zincGray.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 18,
                        color: KineticTokens.primaryContainer,
                      ),
                      Text(
                        'classes.manager.schedule_new'.tr().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: KineticTokens.zincGray.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                )
              : Icon(
                  Icons.add,
                  size: 16,
                  color: KineticTokens.zincGray.withValues(alpha: 0.35),
                ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.coachLabel,
    required this.selected,
    required this.onTap,
  });

  final ClassSession session;
  final String coachLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final inSession =
        !now.isBefore(session.startsAt) && now.isBefore(session.endsAt);

    return Material(
      color: selected
          ? KineticTokens.primaryContainer.withValues(alpha: 0.15)
          : KineticTokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: BorderDirectional(
              start: BorderSide(
                color: selected || inSession
                    ? KineticTokens.electricLime
                    : KineticTokens.secondaryContainer,
                width: 3,
              ),
              top: selected
                  ? const BorderSide(color: KineticTokens.electricLime)
                  : BorderSide.none,
              end: selected
                  ? const BorderSide(color: KineticTokens.electricLime)
                  : BorderSide.none,
              bottom: selected
                  ? const BorderSide(color: KineticTokens.electricLime)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 6, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? KineticTokens.electricLime
                      : KineticTokens.pureWhite,
                ),
              ),
              const Spacer(),
              Text(
                coachLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC4C9AC),
                ),
              ),
              if (inSession) ...[
                const SizedBox(height: 2),
                Text(
                  'classes.manager.in_session'.tr().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: KineticTokens.electricLime,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
