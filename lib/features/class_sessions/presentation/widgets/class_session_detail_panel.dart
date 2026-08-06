import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/class_session.dart';
import '../cubit/class_sessions_cubit.dart';
import '../fixtures/class_manager_stitch_fixtures.dart';
import '../screens/class_manager_screen.dart';

/// Right/start detail panel — attendee chrome fixtures (FEAT-18).
class ClassSessionDetailPanel extends StatelessWidget {
  const ClassSessionDetailPanel({
    super.key,
    required this.canWrite,
    required this.session,
    required this.coaches,
  });

  final bool canWrite;
  final ClassSession? session;
  final List<ClassCoachOption> coaches;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest,
        border: BorderDirectional(
          start: BorderSide(
            color: KineticTokens.zincGray.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: session == null
          ? Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(24),
                child: Text(
                  'classes.detail.empty'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFC4C9AC)),
                ),
              ),
            )
          : _SessionDetailBody(
              canWrite: canWrite,
              session: session!,
              coaches: coaches,
            ),
    );
  }
}

class _SessionDetailBody extends StatelessWidget {
  const _SessionDetailBody({
    required this.canWrite,
    required this.session,
    required this.coaches,
  });

  final bool canWrite;
  final ClassSession session;
  final List<ClassCoachOption> coaches;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final active =
        !now.isBefore(session.startsAt) && now.isBefore(session.endsAt);
    final timeRange =
        '${DateFormat.jm(context.locale.toString()).format(session.startsAt)}'
        ' — '
        '${DateFormat.jm(context.locale.toString()).format(session.endsAt)}';
    final booked = ClassManagerStitchFixtures.fixtureBooked;
    final capacity = session.capacity;
    final progress = (booked / capacity).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (active)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KineticTokens.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'classes.detail.active_now'.tr().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: KineticTokens.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (canWrite && session.isScheduled)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: KineticTokens.zincGray,
                      ),
                      color: KineticTokens.surfaceContainerHigh,
                      onSelected: (value) {
                        final cubit = context.read<ClassSessionsCubit>();
                        if (value == 'edit') {
                          cubit.beginEdit(session);
                        } else if (value == 'cancel') {
                          cubit.softCancel(session);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('classes.detail.edit'.tr()),
                        ),
                        PopupMenuItem(
                          value: 'cancel',
                          child: Text('classes.detail.soft_cancel'.tr()),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                session.title.toUpperCase(),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: KineticTokens.pureWhite,
                ),
              ),
              const SizedBox(height: 12),
              _MetaRow(icon: Icons.schedule, label: timeRange),
              const SizedBox(height: 8),
              _MetaRow(
                icon: Icons.person_outline,
                label: coachLabelFor(coaches, session.coachEmployeeId),
              ),
              const SizedBox(height: 20),
              Text(
                'classes.detail.capacity'.tr().toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: Color(0xFFC4C9AC),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$booked / $capacity',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: KineticTokens.pureWhite,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: KineticTokens.surfaceContainerHigh,
                  color: KineticTokens.electricLime,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0x22FFFFFF)),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 8),
          child: Row(
            children: [
              Text(
                'classes.detail.attendee_list'.tr().toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Color(0xFFC4C9AC),
                ),
              ),
              const Spacer(),
              Text(
                'classes.detail.quick_add'.tr().toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: KineticTokens.zincGray.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            itemCount: ClassManagerStitchFixtures.attendees.length,
            itemBuilder: (context, index) {
              final attendee = ClassManagerStitchFixtures.attendees[index];
              return _AttendeeRow(attendee: attendee);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              foregroundColor: KineticTokens.electricLime,
              disabledForegroundColor: KineticTokens.electricLime,
              side: const BorderSide(color: KineticTokens.electricLime),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'classes.detail.bulk_check_in'.tr().toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFC4C9AC)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: KineticTokens.pureWhite,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow({required this.attendee});

  final ClassAttendeeFixture attendee;

  @override
  Widget build(BuildContext context) {
    final initials = attendee.name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: KineticTokens.surfaceContainerHigh,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: KineticTokens.pureWhite,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: KineticTokens.pureWhite,
                  ),
                ),
                Text(
                  attendee.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC4C9AC),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            attendee.present
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: attendee.present
                ? KineticTokens.electricLime
                : KineticTokens.zincGray,
          ),
        ],
      ),
    );
  }
}
