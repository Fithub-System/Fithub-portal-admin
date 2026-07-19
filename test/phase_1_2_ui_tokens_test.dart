import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/connectivity/presentation/widgets/safe_mode_banner.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/live_occupancy_gauge.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/live_occupancy_ring.dart';

import 'support/localized_pump.dart';

void main() {
  test('Stitch Occupancy gauge tokens match Admin Overview export', () {
    expect(
      KineticTokens.stitchOccupancyScreenId,
      '216e0407184f4c39bd501ed436c1e88b',
    );
    expect(KineticTokens.stitchProjectId, '13435235862240753621');
    expect(KineticTokens.dashboardCardRadius, 12);
    expect(KineticTokens.occupancyCardAccentWidth, 4);
    expect(KineticTokens.occupancyProgressHeight, 16);
    expect(KineticTokens.secondaryContainer.toARGB32(), 0xFF4A8EFF);
    expect(KineticTokens.cyberBlue.toARGB32(), 0xFF007BFF);
    expect(KineticTokens.electricLime.toARGB32(), 0xFFCCFF00);
    expect(KineticTokens.surfaceContainerLow.toARGB32(), 0xFF1C1B1B);
  });

  test('Legacy OccupancyRingPainter still exposes Kinetic stroke/glow', () {
    const painter = OccupancyRingPainter(
      progress: 0.5,
      activeColor: KineticTokens.electricLime,
      trackColor: KineticTokens.zincGray,
    );

    expect(painter.strokeWidth, KineticTokens.occupancyRingStroke);
    expect(painter.glowBlur, KineticTokens.occupancyGlowBlur);
    expect(painter.activeColor.toARGB32(), 0xFFCCFF00);
  });

  testWidgets('SafeMode banner uses 24px zinc gray bar', (tester) async {
    await pumpLocalizedApp(
      tester,
      const Scaffold(body: SafeModeBanner(visible: true)),
      waitFor: find.text('Pulse SafeMode: data is saved locally'),
    );

    expect(find.text('Pulse SafeMode: data is saved locally'), findsOneWidget);

    final bannerSize = tester.getSize(
      find.byKey(const ValueKey('safe-mode-on')),
    );
    expect(bannerSize.height, KineticTokens.safeModeBannerHeight);

    final banner = tester.widget<Container>(
      find.byKey(const ValueKey('safe-mode-on')),
    );
    expect(banner.color, KineticTokens.zincGray);
  });

  testWidgets('Live occupancy gauge renders Stitch count and labels', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      const Scaffold(
        body: SingleChildScrollView(
          child: LiveOccupancyGauge(current: 80, capacity: 100),
        ),
      ),
      waitFor: find.textContaining('80'),
    );

    expect(find.textContaining('80'), findsOneWidget);
    expect(find.textContaining('100'), findsOneWidget);
    expect(find.text('LIVE OCCUPANCY'), findsOneWidget);
    expect(find.text('REAL-TIME GYM FLOOR STATUS'), findsOneWidget);
    expect(find.text('PEAK HOUR: 06:00 PM'), findsOneWidget);
  });
}
