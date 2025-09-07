import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './opportunity_card.dart';

class OpportunitiesFeed extends StatefulWidget {
  final List<Map<String, dynamic>> opportunities;
  final bool isOperator;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final bool isLoading;

  const OpportunitiesFeed({
    Key? key,
    required this.opportunities,
    required this.isOperator,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<OpportunitiesFeed> createState() => _OpportunitiesFeedState();
}

class _OpportunitiesFeedState extends State<OpportunitiesFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Opportunities',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'LIVE',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              widget.onRefresh();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppTheme.lightTheme.colorScheme.primary,
            child: widget.opportunities.isEmpty && !widget.isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: widget.opportunities.length +
                        (widget.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == widget.opportunities.length) {
                        return _buildLoadingIndicator();
                      }

                      final opportunity = widget.opportunities[index];
                      return OpportunityCard(
                        opportunity: opportunity,
                        isOperator: widget.isOperator,
                        onTap: () =>
                            _showOpportunityDetails(context, opportunity),
                        onWatchlistTap: () => _addToWatchlist(opportunity),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Opportunities Available',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Pull to refresh or check your connection',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  void _showOpportunityDetails(
      BuildContext context, Map<String, dynamic> opportunity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Container(
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Opportunity Details',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: _buildOpportunityDetails(opportunity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityDetails(Map<String, dynamic> opportunity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection('Basic Information', [
          _buildDetailRow('Token Pair', opportunity['tokenPair'] ?? 'Unknown'),
          _buildDetailRow('Protocol', opportunity['protocol'] ?? 'Unknown'),
          _buildDetailRow('Risk Level', opportunity['riskLevel'] ?? 'Medium'),
          _buildDetailRow('Profit Margin',
              '+${(opportunity['profitMargin'] as double?)?.toStringAsFixed(2) ?? '0.00'}%'),
        ]),
        SizedBox(height: 3.h),
        _buildDetailSection('Financial Details', [
          _buildDetailRow('Required Capital',
              '\$${opportunity['requiredCapital'] ?? '0.00'}'),
          _buildDetailRow('Estimated Profit',
              '\$${opportunity['estimatedProfit'] ?? '0.00'}'),
          _buildDetailRow('Gas Fee', '\$${opportunity['gasFee'] ?? '0.00'}'),
          _buildDetailRow(
              'Net Profit', '\$${_calculateNetProfit(opportunity)}'),
        ]),
        SizedBox(height: 3.h),
        _buildDetailSection('Technical Details', [
          _buildDetailRow(
              'Block Number', '${opportunity['blockNumber'] ?? 'Unknown'}'),
          _buildDetailRow(
              'Transaction Hash', opportunity['txHash'] ?? 'Not available'),
          _buildDetailRow('Timestamp',
              _formatFullTimestamp(opportunity['timestamp'] as DateTime?)),
        ]),
        if (widget.isOperator) ...[
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/execution-request-flow');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'Execute Opportunity',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateNetProfit(Map<String, dynamic> opportunity) {
    final estimatedProfit =
        double.tryParse(opportunity['estimatedProfit']?.toString() ?? '0') ??
            0.0;
    final gasFee =
        double.tryParse(opportunity['gasFee']?.toString() ?? '0') ?? 0.0;
    final netProfit = estimatedProfit - gasFee;
    return netProfit.toStringAsFixed(2);
  }

  String _formatFullTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _addToWatchlist(Map<String, dynamic> opportunity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${opportunity['tokenPair']} to watchlist'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
