import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/financial_metrics_section.dart';
import './widgets/historical_performance_section.dart';
import './widgets/modal_actions_section.dart';
import './widgets/opportunity_header_widget.dart';
import './widgets/opportunity_overview_section.dart';
import './widgets/parameter_adjustment_section.dart';
import './widgets/risk_assessment_section.dart';

class OpportunityDetailsModal extends StatefulWidget {
  final Map<String, dynamic>? opportunityData;

  const OpportunityDetailsModal({
    Key? key,
    this.opportunityData,
  }) : super(key: key);

  @override
  State<OpportunityDetailsModal> createState() =>
      _OpportunityDetailsModalState();
}

class _OpportunityDetailsModalState extends State<OpportunityDetailsModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // User preferences
  bool isOperator = true; // This should come from user authentication

  // Parameter state
  double _selectedAmount = 10000.0;
  double _gasPriceGwei = 20.0;
  double _slippageTolerance = 0.5;

  // Mock opportunity data
  late Map<String, dynamic> _opportunity;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize opportunity data
    _opportunity = widget.opportunityData ?? _getMockOpportunityData();

    // Start animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getMockOpportunityData() {
    return {
      'id': 'OP-2025-001',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'tokenPair': 'ETH/USDC',
      'protocol': 'Uniswap V3',
      'profitMargin': 8.75,
      'estimatedProfit': '875.50',
      'requiredCapital': '10,000.00',
      'gasFee': '45.32',
      'riskLevel': 'Medium',
      'liquidityDepth': 'High',
      'executionProbability': 0.92,
      'smartContractRisk': 'Verified',
      'poolLiquidity': '\$2.5M',
      'volume24h': '\$12.8M',
      'apr': '12.4%',
      'slippageImpact': '0.15%',
      'blockExpiry': '14:32:15',
      'successRate': 0.87,
      'historicalData': [
        {'time': '10:00', 'profit': 5.2},
        {'time': '10:15', 'profit': 6.8},
        {'time': '10:30', 'profit': 4.9},
        {'time': '10:45', 'profit': 7.3},
        {'time': '11:00', 'profit': 8.1},
        {'time': '11:15', 'profit': 6.5},
        {'time': '11:30', 'profit': 8.7},
      ],
      'riskFactors': [
        'Smart contract not verified',
        'Low liquidity pool',
        'High slippage risk',
        'Network congestion',
      ],
    };
  }

  void _updateCalculations() {
    setState(() {
      // Recalculate profit based on new parameters
      final baseProfit = _opportunity['profitMargin'] as double;
      final adjustedProfit = baseProfit * (_selectedAmount / 10000);
      _opportunity['estimatedProfit'] = adjustedProfit.toStringAsFixed(2);

      // Update gas costs based on gas price
      final baseGas = 45.32;
      final adjustedGas = baseGas * (_gasPriceGwei / 20.0);
      _opportunity['gasFee'] = adjustedGas.toStringAsFixed(2);
    });
  }

  void _handleClose() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _handleExecute() {
    // Show confirmation and navigate to execution flow
    Navigator.of(context).pushNamed(
      AppRoutes.executionRequestFlow,
      arguments: {
        'opportunity': _opportunity,
        'parameters': {
          'amount': _selectedAmount,
          'gasPrice': _gasPriceGwei,
          'slippage': _slippageTolerance,
        },
      },
    );
  }

  void _handleAddToWatchlist() {
    // Add to watchlist functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${_opportunity['tokenPair']} to watchlist',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleShare() {
    // Share opportunity functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opportunity details shared',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: _handleClose,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: SlideTransition(
            position: _slideAnimation,
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(top: 2.h),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      OpportunityHeaderWidget(
                        opportunity: _opportunity,
                        onClose: _handleClose,
                        onShare: _handleShare,
                      ),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),

                              // Opportunity Overview
                              OpportunityOverviewSection(
                                opportunity: _opportunity,
                              ),

                              SizedBox(height: 3.h),

                              // Financial Metrics
                              FinancialMetricsSection(
                                opportunity: _opportunity,
                              ),

                              SizedBox(height: 3.h),

                              // Risk Assessment
                              RiskAssessmentSection(
                                opportunity: _opportunity,
                              ),

                              SizedBox(height: 3.h),

                              // Historical Performance
                              HistoricalPerformanceSection(
                                opportunity: _opportunity,
                              ),

                              SizedBox(height: 3.h),

                              // Parameter Adjustment (for operators only)
                              if (isOperator) ...[
                                ParameterAdjustmentSection(
                                  selectedAmount: _selectedAmount,
                                  gasPriceGwei: _gasPriceGwei,
                                  slippageTolerance: _slippageTolerance,
                                  onAmountChanged: (value) {
                                    setState(() => _selectedAmount = value);
                                    _updateCalculations();
                                  },
                                  onGasPriceChanged: (value) {
                                    setState(() => _gasPriceGwei = value);
                                    _updateCalculations();
                                  },
                                  onSlippageChanged: (value) {
                                    setState(() => _slippageTolerance = value);
                                    _updateCalculations();
                                  },
                                ),
                                SizedBox(height: 3.h),
                              ],

                              // Bottom spacing for floating action buttons
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),

      // Floating Action Buttons
      floatingActionButton: SlideTransition(
        position: _slideAnimation,
        child: ModalActionsSection(
          isOperator: isOperator,
          onExecute: _handleExecute,
          onAddToWatchlist: _handleAddToWatchlist,
          opportunity: _opportunity,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
