import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/connectivity/presentation/widgets/safe_mode_banner.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/live_occupancy_ring.dart';

import 'support/localized_pump.dart';

void main() {
  test('OccupancyRingPainter uses Kinetic Monolith stroke and glow tokens', () {
    const painter = OccupancyRingPainter(
      progress: 0.5,
      activeColor: KineticTokens.electricLime,
      trackColor: KineticTokens.zincGray,
    );

    expect(painter.strokeWidth, KineticTokens.occupancyRingStroke);
    expect(painter.glowBlur, KineticTokens.occupancyGlowBlur);
    expect(painter.activeColor.toARGB32(), 0xFFCCFF00);
    expect(painter.trackColor.toARGB32(), 0xFF6E6E73);
    expect(KineticTokens.occupancyRingSize, 220);
    expect(KineticTokens.occupancyRingStroke, 12);
    expect(KineticTokens.dashboardCardRadius, 16);
    expect(KineticTokens.occupancyGlowBlur, 20);
    expect(KineticTokens.gunmetalCard.toARGB32(), 0xFF1A1A1A);
  });

  test('OccupancyRingPainter shouldRepaint when progress changes', () {
    const a = OccupancyRingPainter(
      progress: 0.2,
      activeColor: KineticTokens.electricLime,
      trackColor: KineticTokens.zincGray,
    );
    const b = OccupancyRingPainter(
      progress: 0.8,
      activeColor: KineticTokens.electricLime,
      trackColor: KineticTokens.zincGray,
    );
    expect(a.shouldRepaint(b), isTrue);
    expect(a.shouldRepaint(a), isFalse);
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

  testWidgets('Live occupancy ring renders current and capacity', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      const Scaffold(body: LiveOccupancyRing(current: 42, capacity: 120)),
      waitFor: find.text('42'),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('/ 120'), findsOneWidget);
    expect(find.text('LIVE OCCUPANCY'), findsOneWidget);

    final paintFinder = find.byType(CustomPaint);
    expect(paintFinder, findsWidgets);

    final customPaint = tester
        .widgetList<CustomPaint>(paintFinder)
        .firstWhere((w) => w.painter is OccupancyRingPainter);
    final painter = customPaint.painter! as OccupancyRingPainter;
    expect(painter.activeColor, KineticTokens.electricLime);
    expect(painter.strokeWidth, KineticTokens.occupancyRingStroke);
    expect(painter.glowBlur, KineticTokens.occupancyGlowBlur);
  });
}
