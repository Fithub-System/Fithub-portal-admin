import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/class_session.dart';
import '../cubit/class_sessions_cubit.dart';
import '../widgets/class_session_detail_panel.dart';
import '../widgets/class_session_form_panel.dart';
import '../widgets/class_weekly_schedule_grid.dart';

/// FEAT-18 Class Manager — Stitch C1 EN/AR.
///
/// EN `40cc7e5d1f27417f9e6681c0fe14b180` · AR `3f356939493b4a79980687040e5e4fa2`.
class ClassManagerScreen extends StatefulWidget {
  const ClassManagerScreen({super.key, required this.canWrite});

  final bool canWrite;

  static const String stitchScreenIdEn = '40cc7e5d1f27417f9e6681c0fe14b180';
  static const String stitchScreenIdAr = '3f356939493b4a79980687040e5e4fa2';
  static const String stitchScreenTitle = 'Class Manager';

  @override
  State<ClassManagerScreen> createState() => _ClassManagerScreenState();
}

class _ClassManagerScreenState extends State<ClassManagerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClassSessionsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr
        ? ClassManagerScreen.stitchScreenIdAr
        : ClassManagerScreen.stitchScreenIdEn;

    return Scaffold(
      backgroundColor: KineticTokens.stitchBackground,
      body: BlocConsumer<ClassSessionsCubit, ClassSessionsState>(
        listenWhen: (prev, next) =>
            prev.messageKey != next.messageKey && next.messageKey != null,
        listener: (context, state) {
          final key = state.messageKey;
          if (key == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(key.tr())),
          );
        },
        builder: (context, state) {
          if (state.status == ClassSessionsStatus.loading &&
              state.sessions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: KineticTokens.electricLime,
              ),
            );
          }

          if (state.status == ClassSessionsStatus.failure &&
              state.sessions.isEmpty) {
            return _ErrorBody(
              messageKey: state.messageKey ?? 'classes.error.unknown',
              onRetry: () => context.read<ClassSessionsCubit>().load(),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1100;
              final main = _MainColumn(
                canWrite: widget.canWrite,
                state: state,
                stitchId: stitchId,
              );
              final detail = ClassSessionDetailPanel(
                canWrite: widget.canWrite,
                session: state.selectedSession,
                coaches: state.coaches,
              );

              if (!wide) {
                return ListView(
                  padding: const EdgeInsetsDirectional.all(24),
                  children: [
                    main,
                    const SizedBox(height: 24),
                    SizedBox(height: 520, child: detail),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.all(32),
                      child: main,
                    ),
                  ),
                  SizedBox(
                    width: 384,
                    child: detail,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.canWrite,
    required this.state,
    required this.stitchId,
  });

  final bool canWrite;
  final ClassSessionsState state;
  final String stitchId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<ClassSessionsCubit>();
    final rangeLabel = _weekRangeLabel(context, state.weekStart, state.weekEnd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'classes.manager.title'.tr().toUpperCase(),
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: KineticTokens.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rangeLabel,
                    style: textTheme.labelMedium?.copyWith(
                      fontSize: 13,
                      letterSpacing: 0.6,
                      color: const Color(0xFFC4C9AC),
                    ),
                  ),
                ],
              ),
            ),
            _WeekNav(
              onPrev: () => cubit.shiftWeek(-1),
              onToday: cubit.goToToday,
              onNext: () => cubit.shiftWeek(1),
            ),
          ],
        ),
        const SizedBox(height: 28),
        ClassWeeklyScheduleGrid(
          canWrite: canWrite,
          weekStart: state.weekStart,
          sessions: state.sessionsInWeek,
          coaches: state.coaches,
          selectedSessionId: state.selectedSessionId,
          onSelect: cubit.selectSession,
          onScheduleSlot: (startsAt) {
            cubit.beginDraftSlot(
              startsAt: startsAt,
              endsAt: startsAt.add(const Duration(hours: 1)),
            );
          },
        ),
        const SizedBox(height: 28),
        ClassSessionFormPanel(
          canWrite: canWrite,
          busy: state.busy,
          coaches: state.coaches,
          editing: state.editingSession,
          draftStartsAt: state.draftStartsAt,
          draftEndsAt: state.draftEndsAt,
        ),
        const SizedBox(height: 12),
        Text(
          'home.coming_soon.stitch_ref'.tr(namedArgs: {'id': stitchId}),
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: KineticTokens.zincGray.withValues(alpha: 0.7),
          ),
        ),
        if (!canWrite) ...[
          const SizedBox(height: 8),
          Text(
            'classes.read_only_hint'.tr(),
            style: textTheme.bodySmall?.copyWith(
              color: KineticTokens.electricLime,
            ),
          ),
        ],
      ],
    );
  }

  String _weekRangeLabel(BuildContext context, DateTime start, DateTime end) {
    final locale = context.locale.toString();
    final fmt = DateFormat('MMMM d', locale);
    final left = fmt.format(start).toUpperCase();
    final right = fmt.format(end).toUpperCase();
    return '$left — $right';
  }
}

class _WeekNav extends StatelessWidget {
  const _WeekNav({
    required this.onPrev,
    required this.onToday,
    required this.onNext,
  });

  final VoidCallback onPrev;
  final VoidCallback onToday;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavIconButton(icon: Icons.chevron_left, onTap: onPrev),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: onToday,
          style: OutlinedButton.styleFrom(
            foregroundColor: KineticTokens.pureWhite,
            side: BorderSide(
              color: KineticTokens.zincGray.withValues(alpha: 0.4),
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          child: Text(
            'classes.manager.today'.tr().toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _NavIconButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: KineticTokens.zincGray.withValues(alpha: 0.4),
            ),
          ),
          child: Icon(icon, size: 20, color: KineticTokens.pureWhite),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.messageKey, required this.onRetry});

  final String messageKey;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: KineticTokens.pureWhite),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: KineticTokens.primaryContainer,
                foregroundColor: KineticTokens.onPrimaryContainer,
              ),
              child: Text('classes.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coach display helper shared by grid / detail.
String coachLabelFor(
  List<ClassCoachOption> coaches,
  String? coachEmployeeId,
) {
  if (coachEmployeeId == null) return '—';
  for (final c in coaches) {
    if (c.id == coachEmployeeId) return c.name.toUpperCase();
  }
  return '—';
}
