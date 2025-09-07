import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/kpi_dashboard.dart';
import './widgets/opportunities_feed.dart';
import './widgets/wallet_status_bar.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isWalletConnected = false;
  String _walletAddress = '';
  bool _isSystemHealthy = true;
  bool _isOperator = true; // Mock user role
  bool _isLoading = false;
  int _selectedBottomNavIndex = 0;

  // Mock data
  final List<Map<String, dynamic>> _opportunities = [
    {
      "id": 1,
      "tokenPair": "ETH/USDC",
      "protocol": "Uniswap V3",
      "profitMargin": 7.25,
      "estimatedProfit": "245.80",
      "requiredCapital": "5000.00",
      "gasFee": "12.50",
      "riskLevel": "Low",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 2)),
      "blockNumber": 18456789,
      "txHash": "0x1234567890abcdef1234567890abcdef12345678",
    },
    {
      "id": 2,
      "tokenPair": "WBTC/DAI",
      "protocol": "SushiSwap",
      "profitMargin": 4.15,
      "estimatedProfit": "156.30",
      "requiredCapital": "3500.00",
      "gasFee": "18.75",
      "riskLevel": "Medium",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "blockNumber": 18456785,
      "txHash": "0xabcdef1234567890abcdef1234567890abcdef12",
    },
    {
      "id": 3,
      "tokenPair": "LINK/USDT",
      "protocol": "Curve Finance",
      "profitMargin": 12.80,
      "estimatedProfit": "892.40",
      "requiredCapital": "8000.00",
      "gasFee": "25.60",
      "riskLevel": "High",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 8)),
      "blockNumber": 18456780,
      "txHash": "0x567890abcdef1234567890abcdef1234567890ab",
    },
    {
      "id": 4,
      "tokenPair": "AAVE/ETH",
      "protocol": "Balancer",
      "profitMargin": 3.45,
      "estimatedProfit": "98.75",
      "requiredCapital": "2800.00",
      "gasFee": "14.20",
      "riskLevel": "Low",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 12)),
      "blockNumber": 18456775,
      "txHash": "0x890abcdef1234567890abcdef1234567890abcdef",
    },
    {
      "id": 5,
      "tokenPair": "UNI/WETH",
      "protocol": "1inch",
      "profitMargin": 6.90,
      "estimatedProfit": "324.50",
      "requiredCapital": "4500.00",
      "gasFee": "16.80",
      "riskLevel": "Medium",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
      "blockNumber": 18456770,
      "txHash": "0xcdef1234567890abcdef1234567890abcdef1234",
    },
  ];

  final Map<String, dynamic> _kpiData = {
    "totalOpportunities": 127,
    "successRate": 94.2,
    "avgProfit": "287.65",
    "activeTasks": 8,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _simulateWalletConnection();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _simulateWalletConnection() {
    // Simulate wallet connection after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isWalletConnected = true;
          _walletAddress = '0x742d35Cc6634C0532925a3b8D4C9db96590e4CAF';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          WalletStatusBar(
            isWalletConnected: _isWalletConnected,
            walletAddress: _walletAddress,
            isSystemHealthy: _isSystemHealthy,
            onWalletTap: _handleWalletTap,
          ),
          Expanded(
            child: _selectedBottomNavIndex == 0
                ? _buildMainDashboard()
                : _buildOtherScreenPlaceholder(),
          ),
        ],
      ),
      floatingActionButton: _isOperator && _selectedBottomNavIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/execution-request-flow'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: CustomIconWidget(
                iconName: 'flash_on',
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Quick Execute',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.secondary,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _selectedBottomNavIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.secondary,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'task_alt',
              color: _selectedBottomNavIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.secondary,
              size: 24,
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'subscriptions',
              color: _selectedBottomNavIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.secondary,
              size: 24,
            ),
            label: 'Subscriptions',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: _selectedBottomNavIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.secondary,
              size: 24,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KpiDashboard(kpiData: _kpiData),
          SizedBox(height: 2.h),
          SizedBox(
            height: 60.h, // Fixed height for opportunities feed
            child: OpportunitiesFeed(
              opportunities: _opportunities,
              isOperator: _isOperator,
              onRefresh: _handleRefresh,
              onLoadMore: _handleLoadMore,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherScreenPlaceholder() {
    String screenName = '';
    String route = '';

    switch (_selectedBottomNavIndex) {
      case 1:
        screenName = 'Task Monitoring';
        route = '/task-monitoring-screen';
        break;
      case 2:
        screenName = 'Subscription Management';
        route = '/subscription-management-screen';
        break;
      case 3:
        screenName = 'Settings';
        route = '/settings-screen';
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'construction',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              screenName,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'This screen is under development',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            // ElevatedButton(
            //   onPressed: () {
            //     if (route.isNotEmpty) {
            //       Navigator.pushNamed(context, route);
            //     }
            //   },
            //   child: Text('Navigate to $screenName'),
            // ),
          ],
        ),
      ),
    );
  }

  void _handleWalletTap() {
    if (!_isWalletConnected) {
      Navigator.pushNamed(context, '/authentication-screen');
    } else {
      _showWalletOptions();
    }
  }

  void _showWalletOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            SizedBox(height: 3.h),
            Text(
              'Wallet Options',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'View Wallet Details',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _showWalletDetails();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Disconnect Wallet',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _disconnectWallet();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showWalletDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Wallet Details',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _walletAddress,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Status: Connected',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _disconnectWallet() {
    setState(() {
      _isWalletConnected = false;
      _walletAddress = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wallet disconnected'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
  }

  void _handleRefresh() {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Add new mock opportunity at the beginning
          _opportunities.insert(0, {
            "id": _opportunities.length + 1,
            "tokenPair": "MATIC/USDC",
            "protocol": "QuickSwap",
            "profitMargin": 5.75,
            "estimatedProfit": "189.25",
            "requiredCapital": "3200.00",
            "gasFee": "8.50",
            "riskLevel": "Low",
            "timestamp": DateTime.now(),
            "blockNumber": 18456800,
            "txHash": "0xnew1234567890abcdef1234567890abcdef123456",
          });
        });
      }
    });
  }

  void _handleLoadMore() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading more opportunities
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Add more mock opportunities
          _opportunities.addAll([
            {
              "id": _opportunities.length + 1,
              "tokenPair": "DOT/ETH",
              "protocol": "PancakeSwap",
              "profitMargin": 4.80,
              "estimatedProfit": "145.60",
              "requiredCapital": "2900.00",
              "gasFee": "11.20",
              "riskLevel": "Medium",
              "timestamp": DateTime.now().subtract(const Duration(minutes: 20)),
              "blockNumber": 18456765,
              "txHash": "0xmore1234567890abcdef1234567890abcdef12345",
            },
            {
              "id": _opportunities.length + 2,
              "tokenPair": "ADA/BUSD",
              "protocol": "Trader Joe",
              "profitMargin": 8.30,
              "estimatedProfit": "412.75",
              "requiredCapital": "5500.00",
              "gasFee": "15.90",
              "riskLevel": "High",
              "timestamp": DateTime.now().subtract(const Duration(minutes: 25)),
              "blockNumber": 18456760,
              "txHash": "0xmore2234567890abcdef1234567890abcdef12345",
            },
          ]);
        });
      }
    });
  }
}
