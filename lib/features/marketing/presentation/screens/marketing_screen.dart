import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../../billing/presentation/widgets/billing_charges_section.dart';
import '../../domain/entities/marketing_campaign.dart';
import '../bloc/marketing_bloc.dart';
import '../fixtures/marketing_stitch_fixtures.dart';
import '../widgets/active_promos_panel.dart';
import '../widgets/flash_sale_campaign_form.dart';
import '../widgets/marketing_analytics_chrome.dart';

/// FEAT-23 Growth Engine — Stitch Marketing & Promotions.
///
/// EN `c3207a6938bf40a7872dde7532020ef9` · AR `ced3126ee9584f86b8c0877d4b20a8d8`.
/// Primary chrome: campaigns + ACTIVE PROMOS. Secondary: FEAT-08 Billing.
class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key, required this.canWrite});

  final bool canWrite;

  static const String stitchScreenIdEn =
      MarketingStitchFixtures.stitchScreenIdEn;
  static const String stitchScreenIdAr =
      MarketingStitchFixtures.stitchScreenIdAr;
  static const String stitchScreenTitle = MarketingStitchFixtures.stitchTitle;

  /// FEAT-08 citation alias (same artboard).
  static const String stitchScreenId = stitchScreenIdEn;

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  final _nameController = TextEditingController();
  DateTime? _startsAt;
  DateTime? _endsAt;
  bool _pushEnabled = true;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MarketingBloc>();
    if (bloc.state.status == MarketingStatus.initial) {
      bloc.add(const MarketingLoadRequested());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr
        ? MarketingScreen.stitchScreenIdAr
        : MarketingScreen.stitchScreenIdEn;

    return Scaffold(
      backgroundColor: KineticTokens.stitchBackground,
      body: BlocConsumer<MarketingBloc, MarketingState>(
        listenWhen: (prev, next) =>
            next.messageKey != null && next.messageKey != prev.messageKey,
        listener: (context, state) {
          final key = state.messageKey;
          if (key == null || key.isEmpty) return;
          StitchAuthSnackbar.show(context, key.tr());
        },
        builder: (context, state) {
          if (state.status == MarketingStatus.loading ||
              state.status == MarketingStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(
                color: KineticTokens.electricLime,
              ),
            );
          }

          if (state.status == MarketingStatus.failure &&
              state.campaigns.isEmpty &&
              state.promoCodes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (state.messageKey ?? 'marketing.error.unknown').tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: KineticTokens.zincGray),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.read<MarketingBloc>().add(
                        const MarketingLoadRequested(),
                      ),
                      child: Text('marketing.retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsetsDirectional.all(24),
                children: [
                  Semantics(label: stitchId, child: const SizedBox.shrink()),
                  _GrowthHeader(),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      final flash = FlashSaleCampaignForm(
                        canWrite: widget.canWrite,
                        busy: state.busy,
                        nameController: _nameController,
                        startsAt: _startsAt,
                        endsAt: _endsAt,
                        pushEnabled: _pushEnabled,
                        onPickStart: () => _pickDate(isStart: true),
                        onPickEnd: () => _pickDate(isStart: false),
                        onPushChanged: (v) => setState(() => _pushEnabled = v),
                        onDeploy: _deploy,
                      );
                      final conversion = const ConversionFlowCard();
                      if (!wide) {
                        return Column(
                          children: [
                            flash,
                            const SizedBox(height: 16),
                            conversion,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: flash),
                          const SizedBox(width: 16),
                          Expanded(flex: 4, child: conversion),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      final asset = const AssetLibraryCard();
                      final promos = ActivePromosPanel(
                        canWrite: widget.canWrite,
                        busy: state.busy,
                        promoCodes: state.promoCodes,
                        onCreate: () => _showCreatePromoDialog(context),
                      );
                      if (!wide) {
                        return Column(
                          children: [asset, const SizedBox(height: 16), promos],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: asset),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: promos),
                        ],
                      );
                    },
                  ),
                  if (state.campaigns.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _CampaignList(
                      campaigns: state.campaigns,
                      canWrite: widget.canWrite,
                      busy: state.busy,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const MarketingMetricTiles(),
                  const SizedBox(height: 28),
                  Text(
                    'marketing.billing_secondary_title'.tr(),
                    style: const TextStyle(
                      color: KineticTokens.pureWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'marketing.billing_secondary_subtitle'.tr(),
                    style: const TextStyle(
                      color: KineticTokens.zincGray,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  BillingChargesSection(canWrite: widget.canWrite),
                ],
              ),
              if (state.busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: KineticTokens.electricLime,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startsAt ?? now)
        : (_endsAt ?? (_startsAt ?? now).add(const Duration(days: 3)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startsAt = DateTime(picked.year, picked.month, picked.day);
      } else {
        _endsAt = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      }
    });
  }

  void _deploy() {
    final starts = _startsAt;
    final ends = _endsAt;
    if (starts == null || ends == null) {
      StitchAuthSnackbar.show(context, 'marketing.error.invalid'.tr());
      return;
    }
    context.read<MarketingBloc>().add(
      MarketingDeployCampaignRequested(
        name: _nameController.text,
        startsAt: starts,
        endsAt: ends,
        pushEnabled: _pushEnabled,
      ),
    );
  }

  Future<void> _showCreatePromoDialog(BuildContext context) async {
    final codeController = TextEditingController();
    final percentController = TextEditingController(text: '30');
    DateTime? expiresAt;
    var lifetime = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              backgroundColor: KineticTokens.surfaceContainerLow,
              title: Text(
                'marketing.promos.create'.tr(),
                style: const TextStyle(color: KineticTokens.pureWhite),
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      style: const TextStyle(color: KineticTokens.pureWhite),
                      decoration: InputDecoration(
                        labelText: 'marketing.promos.code_label'.tr(),
                        labelStyle: const TextStyle(
                          color: KineticTokens.zincGray,
                        ),
                      ),
                    ),
                    TextField(
                      controller: percentController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: KineticTokens.pureWhite),
                      decoration: InputDecoration(
                        labelText: 'marketing.promos.percent_label'.tr(),
                        labelStyle: const TextStyle(
                          color: KineticTokens.zincGray,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'marketing.promos.lifetime'.tr(),
                        style: const TextStyle(color: KineticTokens.pureWhite),
                      ),
                      value: lifetime,
                      activeTrackColor: KineticTokens.electricLime,
                      onChanged: (v) => setLocal(() => lifetime = v),
                    ),
                    if (!lifetime)
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate:
                                expiresAt ??
                                DateTime.now().add(const Duration(days: 14)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 3),
                            ),
                          );
                          if (picked != null) {
                            setLocal(() => expiresAt = picked);
                          }
                        },
                        child: Text(
                          expiresAt == null
                              ? 'marketing.promos.pick_expiry'.tr()
                              : DateFormat.yMMMd().format(expiresAt!),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('marketing.cancel'.tr()),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.electricLime,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('marketing.promos.create'.tr()),
                ),
              ],
            );
          },
        );
      },
    );

    final code = codeController.text;
    final percent = int.tryParse(percentController.text.trim());
    final promoExpiresAt = lifetime ? null : expiresAt;
    codeController.dispose();
    percentController.dispose();
    if (created != true || !mounted) return;

    final bloc = context.read<MarketingBloc>();
    bloc.add(
      MarketingCreatePromoRequested(
        code: code,
        percentOff: percent,
        expiresAt: promoExpiresAt,
      ),
    );
  }
}

class _GrowthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'marketing.growth_engine'.tr(),
                style: const TextStyle(
                  color: KineticTokens.secondaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'marketing.promotions'.tr(),
                      style: const TextStyle(
                        color: KineticTokens.pureWhite,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: ' & ',
                      style: TextStyle(
                        color: KineticTokens.pureWhite.withValues(alpha: 0.7),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'marketing.reach'.tr(),
                      style: const TextStyle(
                        color: KineticTokens.secondaryContainer,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: KineticTokens.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: KineticTokens.electricLime.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            'marketing.live_analysis'.tr(),
            style: const TextStyle(
              color: KineticTokens.electricLime,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignList extends StatelessWidget {
  const _CampaignList({
    required this.campaigns,
    required this.canWrite,
    required this.busy,
  });

  final List<MarketingCampaign> campaigns;
  final bool canWrite;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'marketing.campaigns_heading'.tr(),
          style: const TextStyle(
            color: KineticTokens.zincGray,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        ...campaigns.map((c) {
          return Container(
            margin: const EdgeInsetsDirectional.only(bottom: 8),
            padding: const EdgeInsetsDirectional.all(14),
            decoration: BoxDecoration(
              color: KineticTokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          color: KineticTokens.pureWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${DateFormat.yMMMd().format(c.startsAt.toLocal())}'
                        ' → '
                        '${DateFormat.yMMMd().format(c.endsAt.toLocal())}'
                        ' · ${c.status}',
                        style: const TextStyle(
                          color: KineticTokens.zincGray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canWrite && !c.isSoftEnded)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => context.read<MarketingBloc>().add(
                            MarketingSoftEndCampaignRequested(campaign: c),
                          ),
                    child: Text('marketing.soft_end'.tr()),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
