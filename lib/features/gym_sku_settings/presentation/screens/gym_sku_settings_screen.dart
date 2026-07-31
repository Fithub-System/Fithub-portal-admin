import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../../auth/presentation/widgets/stitch_auth_snackbar.dart';
import '../../domain/entities/gym_sku_settings.dart';
import '../bloc/gym_sku_settings_bloc.dart';

/// Gym Settings / SKU & Marketplace — FEAT-10 Install I3 (US-D / §3.2).
///
/// Stitch G2 EN `6cb93d6100314ce8a5d9c1af92c97723` /
/// AR `9541b6e764dd436daa91336b0ce2263b`.
/// Entry: avatar menu or Reports nest — not a rail tab (AC-D4).
class GymSkuSettingsScreen extends StatefulWidget {
  const GymSkuSettingsScreen({
    super.key,
    required this.canWrite,
    this.onClose,
  });

  static const String stitchScreenId = '6cb93d6100314ce8a5d9c1af92c97723';
  static const String stitchScreenIdAr = '9541b6e764dd436daa91336b0ce2263b';
  static const String stitchScreenTitle = 'Gym Settings / SKU & Marketplace';

  /// Admin-only mutate via RPC (Receptionist read-only).
  final bool canWrite;

  /// Optional close when hosted as shell focus overlay.
  final VoidCallback? onClose;

  @override
  State<GymSkuSettingsScreen> createState() => _GymSkuSettingsScreenState();
}

class _GymSkuSettingsScreenState extends State<GymSkuSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GymSkuSettingsBloc>().add(
      const GymSkuSettingsLoadRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isAr = context.locale.languageCode == 'ar';
    final stitchId = isAr
        ? GymSkuSettingsScreen.stitchScreenIdAr
        : GymSkuSettingsScreen.stitchScreenId;

    return BlocConsumer<GymSkuSettingsBloc, GymSkuSettingsState>(
      listenWhen: (prev, next) =>
          next.messageKey != null && next.messageKey != prev.messageKey,
      listener: (context, state) {
        final key = state.messageKey;
        if (key == null || key.isEmpty) return;
        StitchAuthSnackbar.show(context, key.tr());
      },
      builder: (context, state) {
        return ColoredBox(
          color: KineticTokens.deepCharcoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.onClose != null)
                Material(
                  color: KineticTokens.gunmetalCard,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'gym_settings.close'.tr(),
                            onPressed: widget.onClose,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: KineticTokens.electricLime,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'gym_settings.title'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: KineticTokens.pureWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(child: _body(context, state, textTheme, stitchId)),
            ],
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    GymSkuSettingsState state,
    TextTheme textTheme,
    String stitchId,
  ) {
    if (state.status == GymSkuSettingsStatus.loading ||
        state.status == GymSkuSettingsStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: KineticTokens.electricLime),
      );
    }

    if (state.status == GymSkuSettingsStatus.failure && state.saved == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (state.messageKey ?? 'gym_settings.error.unknown').tr(),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: KineticTokens.zincGray,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<GymSkuSettingsBloc>().add(
                  const GymSkuSettingsLoadRequested(),
                ),
                child: Text('gym_settings.retry'.tr()),
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
            if (widget.onClose == null) ...[
              Text(
                'gym_settings.title'.tr(),
                textAlign: TextAlign.start,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: KineticTokens.electricLime,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'gym_settings.subtitle'.tr(),
              textAlign: TextAlign.start,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'home.coming_soon.stitch_ref'.tr(
                namedArgs: {'id': stitchId},
              ),
              textAlign: TextAlign.start,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: KineticTokens.zincGray.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'gym_settings.sku_heading'.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 12),
            _SkuModeCard(
              selected: state.draftSkuMode,
              enabled: widget.canWrite && !state.busy,
              onChanged: (mode) => context.read<GymSkuSettingsBloc>().add(
                GymSkuSettingsSkuModeChanged(mode),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'gym_settings.marketplace_heading'.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'gym_settings.marketplace_hint'.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: KineticTokens.zincGray,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'gym_settings.marketplace_toggle'.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  color: KineticTokens.pureWhite,
                ),
              ),
              subtitle: Text(
                state.marketplaceToggleEnabled
                    ? 'gym_settings.marketplace_network_note'.tr()
                    : 'gym_settings.marketplace_private_note'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: KineticTokens.zincGray,
                ),
              ),
              value: state.draftMarketplaceOptIn,
              activeThumbColor: KineticTokens.electricLime,
              onChanged:
                  widget.canWrite &&
                      state.marketplaceToggleEnabled &&
                      !state.busy
                  ? (value) => context.read<GymSkuSettingsBloc>().add(
                      GymSkuSettingsMarketplaceChanged(value),
                    )
                  : null,
            ),
            if (!widget.canWrite) ...[
              const SizedBox(height: 12),
              Text(
                'gym_settings.read_only_hint'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: KineticTokens.zincGray,
                ),
              ),
            ],
            if (widget.canWrite) ...[
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton(
                  onPressed: state.busy || !state.isDirty
                      ? null
                      : () => context.read<GymSkuSettingsBloc>().add(
                          const GymSkuSettingsSaveRequested(),
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: KineticTokens.electricLime,
                    foregroundColor: KineticTokens.deepCharcoal,
                    disabledBackgroundColor: KineticTokens.zincGray.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  child: Text('gym_settings.cta.save'.tr()),
                ),
              ),
            ],
          ],
        ),
        if (state.busy)
          const ColoredBox(
            color: Color(0x66000000),
            child: Center(
              child: CircularProgressIndicator(
                color: KineticTokens.electricLime,
              ),
            ),
          ),
      ],
    );
  }
}

class _SkuModeCard extends StatelessWidget {
  const _SkuModeCard({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final SkuMode selected;
  final bool enabled;
  final ValueChanged<SkuMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkuModeTile(
          mode: SkuMode.privateCloud,
          selected: selected == SkuMode.privateCloud,
          enabled: enabled,
          titleKey: 'gym_settings.sku.private_cloud.title',
          bodyKey: 'gym_settings.sku.private_cloud.body',
          onTap: () => onChanged(SkuMode.privateCloud),
        ),
        const SizedBox(height: 12),
        _SkuModeTile(
          mode: SkuMode.network,
          selected: selected == SkuMode.network,
          enabled: enabled,
          titleKey: 'gym_settings.sku.network.title',
          bodyKey: 'gym_settings.sku.network.body',
          onTap: () => onChanged(SkuMode.network),
        ),
      ],
    );
  }
}

class _SkuModeTile extends StatelessWidget {
  const _SkuModeTile({
    required this.mode,
    required this.selected,
    required this.enabled,
    required this.titleKey,
    required this.bodyKey,
    required this.onTap,
  });

  final SkuMode mode;
  final bool selected;
  final bool enabled;
  final String titleKey;
  final String bodyKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor = selected
        ? KineticTokens.electricLime
        : KineticTokens.zincGray.withValues(alpha: 0.4);

    return Material(
      color: KineticTokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(KineticTokens.dashboardCardRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              KineticTokens.dashboardCardRadius,
            ),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected
                    ? KineticTokens.electricLime
                    : KineticTokens.zincGray,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr(),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: KineticTokens.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bodyKey.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: KineticTokens.zincGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
