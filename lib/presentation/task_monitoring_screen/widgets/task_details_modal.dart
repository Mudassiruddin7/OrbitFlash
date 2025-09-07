import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './task_status_badge.dart';

class TaskDetailsModal extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailsModal({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = task['status'] ?? 'unknown';
    final String opportunityId = task['opportunityId'] ?? 'N/A';
    final DateTime timestamp = task['timestamp'] ?? DateTime.now();
    final double? profitLoss = task['profitLoss']?.toDouble();
    final String taskType = task['type'] ?? 'Execution';
    final String? errorMessage = task['errorMessage'];
    final Map<String, dynamic>? executionDetails = task['executionDetails'];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textSecondaryLight,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.borderLight, height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
                  _buildInfoSection(
                    'Basic Information',
                    [
                      _buildInfoRow('Task ID', '#${task['id'] ?? 'Unknown'}'),
                      _buildInfoRow('Type', taskType),
                      _buildInfoRow('Status', '',
                          trailing: TaskStatusBadge(status: status)),
                      _buildInfoRow('Created', _formatFullTimestamp(timestamp)),
                      _buildInfoRow('Opportunity ID', opportunityId),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Financial Info
                  if (profitLoss != null)
                    _buildInfoSection(
                      'Financial Details',
                      [
                        _buildInfoRow(
                          'Profit/Loss',
                          '${profitLoss >= 0 ? '+' : ''}\$${profitLoss.toStringAsFixed(2)}',
                          valueColor: profitLoss >= 0
                              ? AppTheme.successLight
                              : AppTheme.errorLight,
                        ),
                      ],
                    ),

                  if (profitLoss != null) SizedBox(height: 3.h),

                  // Execution Details
                  if (executionDetails != null)
                    _buildInfoSection(
                      'Execution Details',
                      [
                        if (executionDetails['gasUsed'] != null)
                          _buildInfoRow(
                              'Gas Used', '${executionDetails['gasUsed']}'),
                        if (executionDetails['gasPrice'] != null)
                          _buildInfoRow('Gas Price',
                              '${executionDetails['gasPrice']} Gwei'),
                        if (executionDetails['txHash'] != null)
                          _buildInfoRow(
                              'Transaction Hash',
                              '${executionDetails['txHash']}'.substring(0, 20) +
                                  '...'),
                        if (executionDetails['blockNumber'] != null)
                          _buildInfoRow('Block Number',
                              '${executionDetails['blockNumber']}'),
                      ],
                    ),

                  if (executionDetails != null) SizedBox(height: 3.h),

                  // Error Details
                  if (errorMessage != null)
                    _buildInfoSection(
                      'Error Details',
                      [
                        _buildInfoRow('Error Message', errorMessage,
                            valueColor: AppTheme.errorLight),
                      ],
                    ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, Widget? trailing}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: AppTheme.borderLight.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: trailing ??
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppTheme.textPrimaryLight,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ),
    );
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.month}/${timestamp.day}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
