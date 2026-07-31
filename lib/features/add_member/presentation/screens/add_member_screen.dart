import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../../memberships/domain/entities/membership_plan.dart';
import '../bloc/add_member_bloc.dart';

/// Stitch G4 Add New Member — Flow A link athlete + Flow B invite stub.
///
/// EN `cd59a129a24449478a5249ccb41635fb` · AR `89fe5d7afb8d4d4384d7e6498bcdd065`
class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key, this.onEnrolled});

  /// Called after successful enroll with i18n message key (sync Drift roster).
  final ValueChanged<String>? onEnrolled;

  static const String stitchScreenIdEn = 'cd59a129a24449478a5249ccb41635fb';
  static const String stitchScreenIdAr = '89fe5d7afb8d4d4384d7e6498bcdd065';
  static const String stitchScreenTitle = 'Add New Member';

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AddMemberBloc>().add(const AddMemberStarted());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: KineticTokens.deepCharcoal,
      appBar: AppBar(
        backgroundColor: KineticTokens.deepCharcoal,
        foregroundColor: KineticTokens.pureWhite,
        title: Text('add_member.title'.tr()),
      ),
      body: BlocConsumer<AddMemberBloc, AddMemberState>(
        listenWhen: (prev, next) =>
            (next.messageKey != null && next.messageKey != prev.messageKey) ||
            (next.status == AddMemberStatus.success &&
                prev.status != AddMemberStatus.success),
        listener: (context, state) {
          if (state.status == AddMemberStatus.success) {
            final key =
                state.messageKey ?? 'add_member.success.enrolled';
            widget.onEnrolled?.call(key);
            Navigator.of(context).maybePop();
            return;
          }
          final key = state.messageKey;
          if (key != null && key.isNotEmpty) {
            StitchAuthSnackbar.show(context, key.tr());
            context.read<AddMemberBloc>().add(const AddMemberMessageCleared());
          }
        },
        builder: (context, state) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'add_member.subtitle'.tr(),
                    textAlign: TextAlign.start,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: KineticTokens.electricLime,
                    labelColor: KineticTokens.electricLime,
                    unselectedLabelColor: KineticTokens.zincGray,
                    tabs: [
                      Tab(text: 'add_member.tab.link'.tr()),
                      Tab(text: 'add_member.tab.invite'.tr()),
                    ],
                  ),
                  const Divider(height: 1, color: KineticTokens.zincGray),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _LinkExistingTab(
                          emailController: _emailController,
                          state: state,
                        ),
                        const _InviteStubTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LinkExistingTab extends StatelessWidget {
  const _LinkExistingTab({
    required this.emailController,
    required this.state,
  });

  final TextEditingController emailController;
  final AddMemberState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final busy = state.busy;

    return ListView(
      padding: const EdgeInsetsDirectional.only(top: 24),
      children: [
        Text(
          'add_member.link_heading'.tr(),
          style: textTheme.labelLarge?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: KineticTokens.zincGray,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          enabled: !busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          style: const TextStyle(color: KineticTokens.pureWhite),
          decoration: InputDecoration(
            labelText: 'add_member.field.email'.tr(),
            hintText: 'add_member.field.email_hint'.tr(),
            filled: true,
            fillColor: KineticTokens.gunmetalCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                KineticTokens.dashboardCardRadius,
              ),
            ),
          ),
          onFieldSubmitted: busy
              ? null
              : (value) => context.read<AddMemberBloc>().add(
                  AddMemberFindRequested(value),
                ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            onPressed: busy
                ? null
                : () => context.read<AddMemberBloc>().add(
                    AddMemberFindRequested(emailController.text),
                  ),
            icon: state.status == AddMemberStatus.finding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text('add_member.cta.find'.tr()),
            style: FilledButton.styleFrom(
              backgroundColor: KineticTokens.electricLime,
              foregroundColor: KineticTokens.deepCharcoal,
            ),
          ),
        ),
        if (state.match != null) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsetsDirectional.all(16),
            decoration: BoxDecoration(
              color: KineticTokens.surfaceContainerLow,
              borderRadius: BorderRadius.circular(
                KineticTokens.dashboardCardRadius,
              ),
              border: Border.all(color: KineticTokens.neutralTrack),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'add_member.match_heading'.tr(),
                  style: textTheme.labelLarge?.copyWith(
                    color: KineticTokens.zincGray,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.match!.fullName,
                  style: textTheme.titleMedium?.copyWith(
                    color: KineticTokens.pureWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.match!.id,
                  style: textTheme.bodySmall?.copyWith(
                    color: KineticTokens.zincGray,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'add_member.field.plan_optional'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: KineticTokens.zincGray,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: state.selectedPlanId,
                  dropdownColor: KineticTokens.gunmetalCard,
                  style: const TextStyle(color: KineticTokens.pureWhite),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: KineticTokens.gunmetalCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        KineticTokens.dashboardCardRadius,
                      ),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('add_member.plan.none'.tr()),
                    ),
                    ...state.plans.map(
                      (MembershipPlan plan) => DropdownMenuItem<String?>(
                        value: plan.id,
                        child: Text(plan.name),
                      ),
                    ),
                  ],
                  onChanged: busy
                      ? null
                      : (value) => context.read<AddMemberBloc>().add(
                          AddMemberPlanSelected(value),
                        ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => context.read<AddMemberBloc>().add(
                          const AddMemberEnrollRequested(),
                        ),
                  icon: state.status == AddMemberStatus.enrolling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text('add_member.cta.enroll'.tr()),
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.electricLime,
                    foregroundColor: KineticTokens.deepCharcoal,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InviteStubTab extends StatelessWidget {
  const _InviteStubTab();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsetsDirectional.only(top: 24),
      children: [
        Text(
          'add_member.invite_heading'.tr(),
          style: textTheme.labelLarge?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: KineticTokens.zincGray,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'add_member.invite_body'.tr(),
          style: textTheme.bodyMedium?.copyWith(
            color: KineticTokens.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.mail_outline),
          label: Text('add_member.cta.send_invite_later'.tr()),
          style: OutlinedButton.styleFrom(
            foregroundColor: KineticTokens.electricLime,
            disabledForegroundColor: KineticTokens.zincGray,
            side: const BorderSide(color: KineticTokens.zincGray),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
}
