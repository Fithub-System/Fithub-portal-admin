import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../cubit/access_scanner_cubit.dart';
import '../cubit/access_scanner_state.dart';
import '../fixtures/access_gate_stitch_fixtures.dart';

/// Stitch G1 Check-in Gate main composition (EN `3629845f…`).
///
/// Camera / manual FEAT-01 path mounts in [scannerViewport]. Fixtures fill
/// stats / last-member / system log per §4.1 when live data is absent.
class CheckInGateLayout extends StatelessWidget {
  const CheckInGateLayout({
    super.key,
    required this.scannerViewport,
    this.occupancyCurrent,
    this.occupancyCapacity,
  });

  /// FEAT-01 / FEAT-12 scanner surface (camera or test stub).
  final Widget scannerViewport;

  /// Optional occupancy override for widget tests.
  final int? occupancyCurrent;
  final int? occupancyCapacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final scanner = _ScannerColumn(viewport: scannerViewport);
        final aside = _AsideColumn(
          occupancyCurrent: occupancyCurrent,
          occupancyCapacity: occupancyCapacity,
        );

        if (!wide) {
          return ListView(
            padding: const EdgeInsetsDirectional.all(24),
            children: [
              scanner,
              const SizedBox(height: 24),
              aside,
            ],
          );
        }

        return Padding(
          padding: const EdgeInsetsDirectional.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: scanner),
              const SizedBox(width: 32),
              Expanded(flex: 4, child: aside),
            ],
          ),
        );
      },
    );
  }
}

class _ScannerColumn extends StatelessWidget {
  const _ScannerColumn({required this.viewport});

  final Widget viewport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: KineticTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: KineticTokens.onSurface.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: KineticTokens.primaryContainer.withValues(alpha: 0.15),
                blurRadius: 30,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            color: KineticTokens.surfaceContainerLowest,
            padding: const EdgeInsetsDirectional.all(32),
            constraints: const BoxConstraints(minHeight: 500),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _ScanViewport(child: viewport),
                  ),
                ),
                const SizedBox(height: 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: const _ConfirmCheckInButton(),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: const _SystemChromeFooters(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _ContextualStatsRow(),
      ],
    );
  }
}

class _ScanViewport extends StatefulWidget {
  const _ScanViewport({required this.child});

  final Widget child;

  @override
  State<_ScanViewport> createState() => _ScanViewportState();
}

class _ScanViewportState extends State<_ScanViewport>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLine;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KineticTokens.gunmetalCard,
          border: Border.all(
            color: KineticTokens.primaryContainer.withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            BlocBuilder<AccessScannerCubit, AccessScannerState>(
              buildWhen: (p, c) =>
                  p.success != c.success ||
                  p.cameraReady != c.cameraReady ||
                  p.isProcessing != c.isProcessing,
              builder: (context, state) {
                final showWaiting = state.success == null && !state.isProcessing;
                if (!showWaiting) return const SizedBox.shrink();
                return IgnorePointer(
                  child: ColoredBox(
                    color: KineticTokens.gunmetalCard.withValues(
                      alpha: state.cameraReady ? 0.55 : 0.92,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 96,
                          color: KineticTokens.primaryContainer.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'access_scanner.gate.ready_waiting'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.4,
                            color: KineticTokens.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _scanLine,
              builder: (context, _) {
                return Align(
                  alignment: Alignment(0, -1 + 2 * _scanLine.value),
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: KineticTokens.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: KineticTokens.primaryContainer.withValues(
                            alpha: 0.7,
                          ),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const PositionedDirectional(
              top: 16,
              start: 16,
              child: Row(
                children: [
                  _HudDot(),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0x33C3F400),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: 16,
              end: 16,
              child: Opacity(
                opacity: 0.4,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: KineticTokens.onSurface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AccessGateStitchFixtures.latHud),
                      Text(AccessGateStitchFixtures.lngHud),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudDot extends StatelessWidget {
  const _HudDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: KineticTokens.primaryContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ConfirmCheckInButton extends StatelessWidget {
  const _ConfirmCheckInButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessScannerCubit, AccessScannerState>(
      buildWhen: (p, c) => p.success != c.success,
      builder: (context, state) {
        final granted = state.success != null;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('check-in-gate-confirm'),
            onPressed: () {
              // Chrome mirrors Stitch grant flash; success already from FEAT-01.
              if (granted) {
                context.read<AccessScannerCubit>().dismissSuccess();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: granted
                  ? KineticTokens.secondaryContainer
                  : KineticTokens.primaryContainer,
              foregroundColor: granted
                  ? const Color(0xFF00285B)
                  : KineticTokens.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: const RoundedRectangleBorder(),
            ),
            icon: Icon(
              granted ? Icons.verified : Icons.check_circle,
              size: 28,
            ),
            label: Text(
              granted
                  ? 'access_scanner.gate.access_granted'.tr()
                  : 'access_scanner.gate.confirm'.tr(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SystemChromeFooters extends StatelessWidget {
  const _SystemChromeFooters();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: KineticTokens.onSurface.withValues(alpha: 0.4),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'access_scanner.gate.system_id'.tr(
              namedArgs: {'id': AccessGateStitchFixtures.systemId},
            ),
            style: style,
          ),
          Text(
            'access_scanner.gate.encryption'.tr(
              namedArgs: {'algo': AccessGateStitchFixtures.encryption},
            ),
            style: style,
          ),
        ],
      ),
    );
  }
}

class _ContextualStatsRow extends StatelessWidget {
  const _ContextualStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'access_scanner.gate.peak_intensity'.tr(),
            value: AccessGateStitchFixtures.peakIntensityValue,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _StatTile(
            label: 'access_scanner.gate.avg_dwell'.tr(),
            value: AccessGateStitchFixtures.avgDwellValue,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _StatTile(
            label: 'access_scanner.gate.guest_passes'.tr(),
            value: AccessGateStitchFixtures.guestPassesValue,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('check-in-gate-stat-$value'),
      padding: const EdgeInsetsDirectional.all(24),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: KineticTokens.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: KineticTokens.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: KineticTokens.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _AsideColumn extends StatelessWidget {
  const _AsideColumn({
    this.occupancyCurrent,
    this.occupancyCapacity,
  });

  final int? occupancyCurrent;
  final int? occupancyCapacity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OccupancyCard(
          occupancyCurrent: occupancyCurrent,
          occupancyCapacity: occupancyCapacity,
        ),
        const SizedBox(height: 32),
        const _LastMemberCard(),
        const SizedBox(height: 24),
        const _SystemLogCard(),
      ],
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({
    this.occupancyCurrent,
    this.occupancyCapacity,
  });

  final int? occupancyCurrent;
  final int? occupancyCapacity;

  @override
  Widget build(BuildContext context) {
    final hasOverride =
        occupancyCurrent != null && occupancyCapacity != null;

    Widget gauge(int current, int capacity) {
      final safeCapacity = capacity <= 0 ? 1 : capacity;
      final fraction = (current / safeCapacity).clamp(0.0, 1.0);
      return Container(
        key: const Key('check-in-gate-occupancy'),
        padding: const EdgeInsetsDirectional.all(32),
        decoration: BoxDecoration(
          color: KineticTokens.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: KineticTokens.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'access_scanner.gate.live_occupancy'.tr(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                    color: KineticTokens.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const Icon(
                  Icons.sensors,
                  color: KineticTokens.primaryContainer,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 192,
              height: 192,
              child: CustomPaint(
                painter: _OccupancyRingPainter(fraction: fraction),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$current',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: KineticTokens.onSurface,
                        ),
                      ),
                      Text(
                        'access_scanner.gate.occupancy_limit'.tr(
                          namedArgs: {'limit': '$capacity'},
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: KineticTokens.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (hasOverride) {
      return gauge(occupancyCurrent!, occupancyCapacity!);
    }

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, dashboard) {
        final bound = dashboard.capacityLimit > 0;
        final current = bound
            ? dashboard.currentOccupancy
            : AccessGateStitchFixtures.occupancyCurrent;
        final capacity = bound
            ? dashboard.capacityLimit
            : AccessGateStitchFixtures.occupancyLimit;
        return gauge(current, capacity);
      },
    );
  }
}

class _OccupancyRingPainter extends CustomPainter {
  _OccupancyRingPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    final track = Paint()
      ..color = const Color(0xFF353534)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    final arc = Paint()
      ..color = KineticTokens.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, track);
    final sweep = 2 * math.pi * fraction;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _OccupancyRingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

class _LastMemberCard extends StatelessWidget {
  const _LastMemberCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessScannerCubit, AccessScannerState>(
      buildWhen: (p, c) => p.success != c.success,
      builder: (context, state) {
        final live = state.success;
        final name = live?.memberName ?? AccessGateStitchFixtures.memberName;
        final plan = AccessGateStitchFixtures.memberPlan;
        final badge = live?.membershipStatus?.toUpperCase() ??
            AccessGateStitchFixtures.memberActiveBadge.toUpperCase();
        final initials = _initials(name);

        return Container(
          key: const Key('check-in-gate-last-member'),
          padding: const EdgeInsetsDirectional.all(24),
          decoration: BoxDecoration(
            color: KineticTokens.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: KineticTokens.primaryContainer.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KineticTokens.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: KineticTokens.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: KineticTokens.railSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: KineticTokens.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: KineticTokens.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: KineticTokens.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan,
                          style: const TextStyle(
                            fontSize: 14,
                            color: KineticTokens.onSurface,
                          ).copyWith(
                            color: const Color(0xFFC4C9AC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: KineticTokens.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'access_scanner.gate.power_score'.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.6,
                      color: KineticTokens.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    AccessGateStitchFixtures.powerScoreValue,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: KineticTokens.secondaryFixedDim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: AccessGateStitchFixtures.powerScoreFraction,
                  minHeight: 4,
                  backgroundColor: KineticTokens.surfaceContainerLowest,
                  color: KineticTokens.secondaryFixedDim,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MiniMeta(
                      label: 'access_scanner.gate.last_check_in'.tr(),
                      value: AccessGateStitchFixtures.lastCheckIn,
                    ),
                  ),
                  Expanded(
                    child: _MiniMeta(
                      label: 'access_scanner.gate.total_visits'.tr(),
                      value: AccessGateStitchFixtures.totalVisits,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return AccessGateStitchFixtures.memberInitials;
    if (parts.length == 1) {
      return parts.first.substring(0, math.min(2, parts.first.length)).toUpperCase();
    }
    return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.8,
            color: const Color(0xFFC4C9AC).withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC4C9AC),
          ),
        ),
      ],
    );
  }
}

class _SystemLogCard extends StatelessWidget {
  const _SystemLogCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('check-in-gate-system-log'),
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: KineticTokens.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'access_scanner.gate.system_log'.tr(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Color(0xFFC4C9AC),
            ),
          ),
          const SizedBox(height: 12),
          ...AccessGateStitchFixtures.systemLog.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Opacity(
                opacity: 0.4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '[${line.time}]',
                      style: const TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        color: KineticTokens.onSurface,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        line.event,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 9,
                          fontFamily: 'monospace',
                          color: KineticTokens.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
