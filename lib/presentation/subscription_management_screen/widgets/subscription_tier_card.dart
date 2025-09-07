import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubscriptionTierCard extends StatelessWidget {
  final Map<String, dynamic> tierData;
  final bool isCurrentTier;
  final VoidCallback? onUpgrade;

  const SubscriptionTierCard({
    Key? key,
    required this.tierData,
    required this.isCurrentTier,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isCurrentTier
            ? (isLight
                ? AppTheme.primaryLight.withValues(alpha: 0.1)
                : AppTheme.primaryDark.withValues(alpha: 0.1))
            : (isLight ? AppTheme.surfaceLight : AppTheme.surfaceDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentTier
              ? (isLight ? AppTheme.primaryLight : AppTheme.primaryDark)
              : (isLight ? AppTheme.borderLight : AppTheme.borderDark),
          width: isCurrentTier ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLight ? AppTheme.shadowLight : AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tierData["name"] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCurrentTier
                                  ? (isLight
                                      ? AppTheme.primaryLight
                                      : AppTheme.primaryDark)
                                  : null,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        tierData["price"] as String,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isLight
                                      ? AppTheme.textPrimaryLight
                                      : AppTheme.textPrimaryDark,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isCurrentTier)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isLight
                          ? AppTheme.successLight
                          : AppTheme.successDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Current",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              tierData["description"] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isLight
                        ? AppTheme.textSecondaryLight
                        : AppTheme.textSecondaryDark,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            ...((tierData["features"] as List).map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: isLight
                            ? AppTheme.successLight
                            : AppTheme.successDark,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          feature as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isLight
                                        ? AppTheme.textPrimaryLight
                                        : AppTheme.textPrimaryDark,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ))),
            if (!isCurrentTier && onUpgrade != null) ...[
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLight ? AppTheme.primaryLight : AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Upgrade",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
