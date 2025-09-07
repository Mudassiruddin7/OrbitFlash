import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SupportedWalletsWidget extends StatelessWidget {
  const SupportedWalletsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> supportedWallets = [
      {
        "name": "MetaMask",
        "icon": "account_balance_wallet",
        "color": Color(0xFFF6851B),
      },
      {
        "name": "WalletConnect",
        "icon": "link",
        "color": Color(0xFF3B99FC),
      },
      {
        "name": "Trust Wallet",
        "icon": "security",
        "color": Color(0xFF3375BB),
      },
      {
        "name": "Coinbase",
        "icon": "account_circle",
        "color": Color(0xFF0052FF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Wallets',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: supportedWallets.map((wallet) {
            return Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: (wallet["color"] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (wallet["color"] as Color).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: wallet["icon"] as String,
                  color: wallet["color"] as Color,
                  size: 6.w,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
