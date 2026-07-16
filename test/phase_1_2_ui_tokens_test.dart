import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fithub_portal_admin/config/theme/kinetic_tokens.dart';
import 'package:fithub_portal_admin/features/connectivity/presentation/widgets/safe_mode_banner.dart';
import 'package:fithub_portal_admin/features/dashboard/presentation/widgets/live_occupancy_ring.dart';

void main() {
  testWidgets('SafeMode banner uses 24px zinc gray bar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SafeModeBanner(visible: true),
        ),
      ),
    );

    expect(find.text(KineticTokens.safeModeMessage), findsOneWidget);

    final bannerSize = tester.getSize(find.byKey(const ValueKey('safe-mode-on')));
    expect(bannerSize.height, KineticTokens.safeModeBannerHeight);

    final banner = tester.widget<Container>(
      find.byKey(const ValueKey('safe-mode-on')),
    );
    expect(banner.color, KineticTokens.zincGray);
  });

  testWidgets('Live occupancy ring renders current and capacity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LiveOccupancyRing(current: 42, capacity: 120),
        ),
      ),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('/ 120'), findsOneWidget);
    expect(find.text('LIVE OCCUPANCY'), findsOneWidget);
  });
}
