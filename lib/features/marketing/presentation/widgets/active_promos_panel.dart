import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../../domain/entities/promo_code.dart';
import '../fixtures/marketing_stitch_fixtures.dart';

/// ACTIVE PROMOS list + Create New Code (AC-C).
class ActivePromosPanel extends StatelessWidget {
  const ActivePromosPanel({
    super.key,
    required this.canWrite,
    required this.busy,
    required this.promoCodes,
    required this.onCreate,
  });

  final bool canWrite;
  final bool busy;
  final List<PromoCode> promoCodes;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final useLive = promoCodes.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: KineticTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'marketing.promos.title'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: canWrite && !busy ? onCreate : null,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text('marketing.promos.create'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: KineticTokens.secondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (useLive)
            ...promoCodes.map((p) => _LivePromoCard(promo: p))
          else
            ...MarketingStitchFixtures.samplePromos.map(
              (row) => _FixturePromoCard(row: row),
            ),
        ],
      ),
    );
  }
}

class _LivePromoCard extends StatelessWidget {
  const _LivePromoCard({required this.promo});
  final PromoCode promo;

  @override
  Widget build(BuildContext context) {
    final badge = promo.isPercent
        ? '${promo.percentOff}% OFF'
        : '${((promo.amountOffCents ?? 0) / 100).toStringAsFixed(0)} '
              '${promo.currency}';
    final expiry = promo.isLifetime
        ? 'marketing.promos.no_expiry'.tr()
        : 'marketing.promos.expires_on'.tr(
            namedArgs: {
              'date': DateFormat.yMMMd().format(promo.expiresAt!.toLocal()),
            },
          );
    return _PromoChrome(
      code: promo.code,
      badge: badge,
      expiry: expiry,
      redeemed: promo.redeemedCount,
      status: promo.status,
      lifetime: promo.isLifetime,
    );
  }
}

class _FixturePromoCard extends StatelessWidget {
  const _FixturePromoCard({required this.row});
  final Map<String, Object?> row;

  @override
  Widget build(BuildContext context) {
    return _PromoChrome(
      code: row['code']! as String,
      badge: row['badge']! as String,
      expiry: row['expiry']! as String,
      redeemed: row['redeemed']! as int,
      status: row['status']! as String,
      lifetime: row['badge'] == 'LIFETIME',
      fixture: true,
    );
  }
}

class _PromoChrome extends StatelessWidget {
  const _PromoChrome({
    required this.code,
    required this.badge,
    required this.expiry,
    required this.redeemed,
    required this.status,
    required this.lifetime,
    this.fixture = false,
  });

  final String code;
  final String badge;
  final String expiry;
  final int redeemed;
  final String status;
  final bool lifetime;
  final bool fixture;

  @override
  Widget build(BuildContext context) {
    final expired = status == 'expired' || status == 'inactive';
    final badgeColor = expired
        ? const Color(0xFFFFB4AB)
        : lifetime
        ? KineticTokens.secondaryContainer
        : KineticTokens.electricLime;
    final badgeFg = expired
        ? const Color(0xFF690005)
        : lifetime
        ? KineticTokens.pureWhite
        : Colors.black;

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: KineticTokens.zincGray.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            expired ? Icons.sell_outlined : Icons.confirmation_number_outlined,
            color: expired
                ? KineticTokens.zincGray
                : KineticTokens.electricLime,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: expired
                        ? KineticTokens.zincGray
                        : KineticTokens.pureWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeFg,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      expiry,
                      style: const TextStyle(
                        color: KineticTokens.zincGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.decimalPattern().format(redeemed),
                style: TextStyle(
                  color: expired
                      ? KineticTokens.zincGray
                      : KineticTokens.pureWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'marketing.promos.redeemed'.tr(),
                style: const TextStyle(
                  color: KineticTokens.zincGray,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              if (fixture)
                Text(
                  'marketing.fixture'.tr(),
                  style: const TextStyle(
                    color: KineticTokens.zincGray,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
