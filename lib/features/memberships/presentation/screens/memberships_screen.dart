import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../cubit/memberships_cubit.dart';
import '../widgets/memberships_plans_panel.dart';

/// Standalone memberships page (legacy FEAT-07). Shell uses
/// [MemberManagementScreen] under Members nav (FEAT-07-R).
class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({super.key, required this.canWrite});

  static const String stitchCompanionScreenId =
      '216e0407184f4c39bd501ed436c1e88b';
  static const String stitchCompanionTitle = 'Admin Overview';

  final bool canWrite;

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'memberships.title'.tr(),
                textAlign: TextAlign.start,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'memberships.subtitle'.tr(),
                textAlign: TextAlign.start,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(child: MembershipsPlansPanel(canWrite: widget.canWrite)),
      ],
    );
  }
}
