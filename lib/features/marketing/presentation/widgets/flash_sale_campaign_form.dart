import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Stitch FLASH SALE campaign form (AC-B3).
class FlashSaleCampaignForm extends StatelessWidget {
  const FlashSaleCampaignForm({
    super.key,
    required this.canWrite,
    required this.busy,
    required this.nameController,
    required this.startsAt,
    required this.endsAt,
    required this.pushEnabled,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onPushChanged,
    required this.onDeploy,
  });

  final bool canWrite;
  final bool busy;
  final TextEditingController nameController;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool pushEnabled;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<bool> onPushChanged;
  final VoidCallback onDeploy;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: KineticTokens.surfaceContainerLow,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ColoredBox(
                color: KineticTokens.electricLime,
                child: SizedBox(width: 3),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'marketing.flash_sale.title'.tr(),
                        style: const TextStyle(
                          color: KineticTokens.pureWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'marketing.flash_sale.subtitle'.tr(),
                        style: const TextStyle(
                          color: Color(0xFFC4C9AC),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('marketing.flash_sale.campaign_name'.tr()),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        enabled: canWrite && !busy,
                        style: const TextStyle(color: KineticTokens.pureWhite),
                        decoration: _inputDecoration(
                          'marketing.flash_sale.campaign_name_hint'.tr(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'marketing.flash_sale.start_window'.tr(),
                              value: startsAt,
                              enabled: canWrite && !busy,
                              onTap: onPickStart,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateField(
                              label: 'marketing.flash_sale.end_window'.tr(),
                              value: endsAt,
                              enabled: canWrite && !busy,
                              onTap: onPickEnd,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: KineticTokens.electricLime,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'marketing.flash_sale.push_title'.tr(),
                                  style: const TextStyle(
                                    color: KineticTokens.pureWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'marketing.flash_sale.push_subtitle'.tr(),
                                  style: const TextStyle(
                                    color: Color(0xFFC4C9AC),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: pushEnabled,
                            onChanged: canWrite && !busy ? onPushChanged : null,
                            activeThumbColor: KineticTokens.onPrimaryContainer,
                            activeTrackColor: KineticTokens.electricLime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: canWrite && !busy ? onDeploy : null,
                          icon: const Icon(Icons.bolt, color: Colors.black),
                          label: Text(
                            'marketing.flash_sale.deploy'.tr(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: KineticTokens.electricLime,
                            disabledBackgroundColor: KineticTokens.zincGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      if (!canWrite) ...[
                        const SizedBox(height: 10),
                        Text(
                          'marketing.read_only_hint'.tr(),
                          style: const TextStyle(
                            color: KineticTokens.zincGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: KineticTokens.zincGray.withValues(alpha: 0.8),
      ),
      filled: true,
      fillColor: const Color(0xFF0E0E0E),
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: KineticTokens.zincGray.withValues(alpha: 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: KineticTokens.zincGray.withValues(alpha: 0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: KineticTokens.electricLime),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFC4C9AC),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? 'mm/dd/yyyy'
        : DateFormat('MM/dd/yyyy').format(value!.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: KineticTokens.zincGray.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: TextStyle(
                      color: value == null
                          ? KineticTokens.zincGray
                          : KineticTokens.pureWhite,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: KineticTokens.zincGray.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
