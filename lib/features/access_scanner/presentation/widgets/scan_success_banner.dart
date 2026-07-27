import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';

/// Green slide-down success notification (FEAT-01 §3 Access Scanner).
class ScanSuccessBanner extends StatelessWidget {
  const ScanSuccessBanner({
    super.key,
    required this.memberName,
    this.avatarUrl,
    required this.onDismiss,
  });

  final String memberName;
  final String? avatarUrl;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          child: Dismissible(
            key: ValueKey('scan-success-$memberName'),
            direction: DismissDirection.up,
            onDismissed: (_) => onDismiss(),
            child: Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _Avatar(avatarUrl: avatarUrl, name: memberName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          memberName,
                          style: const TextStyle(
                            color: KineticTokens.pureWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'access_scanner.success.active_badge'.tr(),
                            style: const TextStyle(
                              color: KineticTokens.pureWhite,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(
                      Icons.close,
                      color: KineticTokens.pureWhite,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl, required this.name});

  final String? avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, _) {},
        child: url.isEmpty ? _initials() : null,
      );
    }
    return CircleAvatar(radius: 24, backgroundColor: KineticTokens.gunmetalCard, child: _initials());
  }

  Widget _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Text(
      initials.isEmpty ? '?' : initials,
      style: const TextStyle(
        color: KineticTokens.electricLime,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
