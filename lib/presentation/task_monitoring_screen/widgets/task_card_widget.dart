import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './task_status_badge.dart';

class TaskCardWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const TaskCardWidget({
    Key? key,
    required this.task,
    this.onTap,
    this.onRetry,
    this.onCancel,
    this.onViewDetails,
    this.isSelected = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = task['status'] ?? 'unknown';
    final String opportunityId = task['opportunityId'] ?? 'N/A';
    final DateTime timestamp = task['timestamp'] ?? DateTime.now();
    final double? profitLoss = task['profitLoss']?.toDouble();
    final String taskType = task['type'] ?? 'Execution';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(task['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (status.toLowerCase() == 'failed' && onRetry != null)
              SlidableAction(
                onPressed: (_) => onRetry!(),
                backgroundColor: AppTheme.warningLight,
                foregroundColor: Colors.white,
                icon: Icons.refresh,
                label: 'Retry',
                borderRadius: BorderRadius.circular(12),
              ),
            if (status.toLowerCase() == 'pending' && onCancel != null)
              SlidableAction(
                onPressed: (_) => onCancel!(),
                backgroundColor: AppTheme.errorLight,
                foregroundColor: Colors.white,
                icon: Icons.cancel,
                label: 'Cancel',
                borderRadius: BorderRadius.circular(12),
              ),
            if (onViewDetails != null)
              SlidableAction(
                onPressed: (_) => onViewDetails!(),
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                icon: Icons.visibility,
                label: 'Details',
                borderRadius: BorderRadius.circular(12),
              ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryLight.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryLight, width: 2)
                  : Border.all(color: AppTheme.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
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
                              'Task #${task['id'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              taskType,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TaskStatusBadge(status: status),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.textSecondaryLight,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'trending_up',
                        color: AppTheme.textSecondaryLight,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Opportunity: $opportunityId',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (profitLoss != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: profitLoss >= 0
                              ? 'arrow_upward'
                              : 'arrow_downward',
                          color: profitLoss >= 0
                              ? AppTheme.successLight
                              : AppTheme.errorLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${profitLoss >= 0 ? '+' : ''}\$${profitLoss.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: profitLoss >= 0
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isSelected) ...[
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
