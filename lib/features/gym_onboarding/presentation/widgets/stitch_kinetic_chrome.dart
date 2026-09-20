import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/kinetic_tokens.dart';
import '../../../../core/i18n/app_locales.dart';
import '../../../../core/network/supabase_locale_headers.dart';

/// Shared Kinetic chrome for FEAT-96 / FEAT-97 Stitch desktop artboards.
///
/// Tokens from Brand Lock + `feat96-assets` / `feat97-assets`:
/// canvas `#121212`, card `#1C1B1B`, lime `#CCFF00`, form max **720**.
abstract final class StitchKineticChrome {
  static const double formMaxWidth = 720;
  static const double cardRadius = 16;
  static const double fieldRadius = 8;
  static const double ctaHeight = 52;
  static const double topBarHeight = 56;
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(32, 28, 32, 28);
}

class StitchPulseTopBar extends StatelessWidget {
  const StitchPulseTopBar({
    super.key,
    this.trailing,
    this.showLocaleToggle = true,
  });

  final Widget? trailing;
  final bool showLocaleToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: StitchKineticChrome.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Text(
              'PULSE',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: KineticTokens.electricLime,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.2,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            if (showLocaleToggle) const _LocaleToggle(),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

class _LocaleToggle extends StatelessWidget {
  const _LocaleToggle();

  @override
  Widget build(BuildContext context) {
    final isEn = context.locale.languageCode == 'en';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip(context, 'EN', isEn, AppLocales.en),
        const SizedBox(width: 6),
        _chip(context, 'العربية', !isEn, AppLocales.ar),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    Locale locale,
  ) {
    return Material(
      color: selected
          ? KineticTokens.electricLime.withValues(alpha: 0.16)
          : KineticTokens.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () async {
          await context.setLocale(locale);
          SupabaseLocaleHeaders.apply(locale.languageCode);
        },
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected
                  ? KineticTokens.electricLime
                  : KineticTokens.zincGray,
            ),
          ),
        ),
      ),
    );
  }
}

class StitchKineticCard extends StatelessWidget {
  const StitchKineticCard({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? StitchKineticChrome.formMaxWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KineticTokens.surfaceContainerLow,
          borderRadius: BorderRadius.circular(StitchKineticChrome.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: KineticTokens.electricLime.withValues(alpha: 0.04),
              blurRadius: 48,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(StitchKineticChrome.cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const ColoredBox(
                color: KineticTokens.electricLime,
                child: SizedBox(height: 2),
              ),
              Padding(padding: StitchKineticChrome.cardPadding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class StitchStageBadge extends StatelessWidget {
  const StitchStageBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: KineticTokens.electricLime,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.4,
      ),
    );
  }
}

class StitchSectionLabel extends StatelessWidget {
  const StitchSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: KineticTokens.zincGray,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class StitchFilledField extends StatelessWidget {
  const StitchFilledField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: KineticTokens.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              color: KineticTokens.pureWhite,
              fontSize: 14,
            ),
            decoration: stitchFilledDecoration(hint: hint),
          ),
        ],
      ),
    );
  }
}

InputDecoration stitchFilledDecoration({String? hint}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(StitchKineticChrome.fieldRadius),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: KineticTokens.zincGray.withValues(alpha: 0.8),
      fontSize: 13,
    ),
    filled: true,
    fillColor: KineticTokens.deepCharcoal,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StitchKineticChrome.fieldRadius),
      borderSide: const BorderSide(color: KineticTokens.electricLime, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(StitchKineticChrome.fieldRadius),
      borderSide: const BorderSide(color: KineticTokens.peakCoral),
    ),
  );
}

class StitchLimeCta extends StatelessWidget {
  const StitchLimeCta({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.enabled = true,
    this.showArrow = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool busy;
  final bool enabled;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.kineticCta,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (!enabled || busy) ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: StitchKineticChrome.ctaHeight,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: KineticTokens.deepCharcoal,
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: const TextStyle(
                              color: KineticTokens.deepCharcoal,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          if (showArrow) ...[
                            const SizedBox(width: 8),
                            Transform.flip(
                              flipX: isRtl,
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: KineticTokens.deepCharcoal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class StitchGhostButton extends StatelessWidget {
  const StitchGhostButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: KineticTokens.zincGray,
        padding: EdgeInsets.zero,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class StitchDashedUpload extends StatelessWidget {
  const StitchDashedUpload({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(),
      child: Container(
        height: compact ? 88 : 128,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: KineticTokens.electricLime.withValues(alpha: 0.85),
              size: compact ? 18 : 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KineticTokens.zincGray,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KineticTokens.electricLime.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const radius = 12.0;
    const dash = 6.0;
    const gap = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StitchConnectedStepper extends StatelessWidget {
  const StitchConnectedStepper({
    super.key,
    required this.step,
    required this.labels,
    required this.onStepTap,
  });

  final int step;
  final List<String> labels;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= step
                      ? KineticTokens.electricLime
                      : KineticTokens.surfaceContainerHigh,
                ),
              ),
            _StepNode(
              index: i,
              label: labels[i],
              active: i == step,
              done: i < step,
              onTap: () => onStepTap(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.index,
    required this.label,
    required this.active,
    required this.done,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool active;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = active || done
        ? KineticTokens.electricLime
        : KineticTokens.surfaceContainerHigh;
    final fg = active || done
        ? KineticTokens.deepCharcoal
        : KineticTokens.zincGray;
    return InkWell(
      key: Key('gym-profile-step-$index'),
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: fill,
            child: done
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: KineticTokens.deepCharcoal,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active
                  ? KineticTokens.electricLime
                  : KineticTokens.zincGray,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class StitchSettingsPills extends StatelessWidget {
  const StitchSettingsPills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  static const ids = ['sku', 'freeze', 'profile', 'operations'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in ids)
          _pill(
            context,
            id: id,
            label: 'settings.hub.modules.$id.pill'.tr(),
            selected: selected == id,
          ),
      ],
    );
  }

  Widget _pill(
    BuildContext context, {
    required String id,
    required String label,
    required bool selected,
  }) {
    return Material(
      color: selected
          ? KineticTokens.electricLime
          : KineticTokens.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: Key('settings-pill-$id'),
        onTap: () => onSelect(id),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: selected
                  ? KineticTokens.deepCharcoal
                  : KineticTokens.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
