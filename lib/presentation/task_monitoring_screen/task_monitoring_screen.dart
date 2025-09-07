import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/task_card_widget.dart';
import './widgets/task_details_modal.dart';

class TaskMonitoringScreen extends StatefulWidget {
  const TaskMonitoringScreen({Key? key}) : super(key: key);

  @override
  State<TaskMonitoringScreen> createState() => _TaskMonitoringScreenState();
}

class _TaskMonitoringScreenState extends State<TaskMonitoringScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Pending',
    'Processing',
    'Completed',
    'Failed'
  ];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedTasks = <String>{};

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data for tasks
  final List<Map<String, dynamic>> _allTasks = [
    {
      "id": "TSK001",
      "type": "Flash Loan Execution",
      "status": "completed",
      "opportunityId": "OPP-2025-001",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
      "profitLoss": 245.67,
      "executionDetails": {
        "gasUsed": 180000,
        "gasPrice": 25,
        "txHash": "0x1234567890abcdef1234567890abcdef12345678",
        "blockNumber": 18500123
      }
    },
    {
      "id": "TSK002",
      "type": "Arbitrage Execution",
      "status": "processing",
      "opportunityId": "OPP-2025-002",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 8)),
      "profitLoss": null,
    },
    {
      "id": "TSK003",
      "type": "Flash Loan Execution",
      "status": "failed",
      "opportunityId": "OPP-2025-003",
      "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
      "profitLoss": -12.34,
      "errorMessage": "Insufficient liquidity in target pool",
      "executionDetails": {
        "gasUsed": 95000,
        "gasPrice": 30,
        "txHash": "0xabcdef1234567890abcdef1234567890abcdef12",
        "blockNumber": 18500089
      }
    },
    {
      "id": "TSK004",
      "type": "MEV Opportunity",
      "status": "pending",
      "opportunityId": "OPP-2025-004",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 2)),
      "profitLoss": null,
    },
    {
      "id": "TSK005",
      "type": "Flash Loan Execution",
      "status": "completed",
      "opportunityId": "OPP-2025-005",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "profitLoss": 89.12,
      "executionDetails": {
        "gasUsed": 165000,
        "gasPrice": 22,
        "txHash": "0x9876543210fedcba9876543210fedcba98765432",
        "blockNumber": 18500045
      }
    },
    {
      "id": "TSK006",
      "type": "Arbitrage Execution",
      "status": "failed",
      "opportunityId": "OPP-2025-006",
      "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
      "profitLoss": -5.67,
      "errorMessage": "Transaction reverted due to slippage",
    },
    {
      "id": "TSK007",
      "type": "Flash Loan Execution",
      "status": "processing",
      "opportunityId": "OPP-2025-007",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 25)),
      "profitLoss": null,
    },
    {
      "id": "TSK008",
      "type": "MEV Opportunity",
      "status": "completed",
      "opportunityId": "OPP-2025-008",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "profitLoss": 156.78,
      "executionDetails": {
        "gasUsed": 210000,
        "gasPrice": 28,
        "txHash": "0xfedcba0987654321fedcba0987654321fedcba09",
        "blockNumber": 18499987
      }
    },
  ];

  List<Map<String, dynamic>> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _filterTasks();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTasks();
    }
  }

  void _filterTasks() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredTasks = List.from(_allTasks);
      } else {
        _filteredTasks = _allTasks
            .where((task) =>
                task['status'].toString().toLowerCase() ==
                _selectedFilter.toLowerCase())
            .toList();
      }
    });
  }

  Future<void> _refreshTasks() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Add new mock task to simulate real-time updates
    final newTask = {
      "id": "TSK${DateTime.now().millisecondsSinceEpoch}",
      "type": "Flash Loan Execution",
      "status": "pending",
      "opportunityId": "OPP-2025-${DateTime.now().millisecondsSinceEpoch}",
      "timestamp": DateTime.now(),
      "profitLoss": null,
    };

    setState(() {
      _allTasks.insert(0, newTask);
      _isLoading = false;
    });

    _filterTasks();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _loadMoreTasks() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    // Simulate loading more data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoadingMore = false;
      // Simulate no more data after some loads
      if (_allTasks.length > 15) {
        _hasMoreData = false;
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _isSelectionMode = false;
      _selectedTasks.clear();
    });
    _filterTasks();
  }

  void _onTaskLongPress(String taskId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = true;
      _selectedTasks.add(taskId);
    });
  }

  void _onTaskTap(String taskId) {
    if (_isSelectionMode) {
      setState(() {
        _selectedTasks.contains(taskId)
            ? _selectedTasks.remove(taskId)
            : _selectedTasks.add(taskId);

        if (_selectedTasks.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      _showTaskDetails(taskId);
    }
  }

  void _showTaskDetails(String taskId) {
    final task = _allTasks.firstWhere((t) => t['id'] == taskId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => TaskDetailsModal(task: task),
      ),
    );
  }

  void _retryTask(String taskId) {
    HapticFeedback.lightImpact();
    final taskIndex = _allTasks.indexWhere((t) => t['id'] == taskId);
    if (taskIndex != -1) {
      setState(() {
        _allTasks[taskIndex]['status'] = 'pending';
        _allTasks[taskIndex]['timestamp'] = DateTime.now();
        _allTasks[taskIndex]['errorMessage'] = null;
      });
      _filterTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task #$taskId queued for retry'),
          backgroundColor: AppTheme.successLight,
        ),
      );
    }
  }

  void _cancelTask(String taskId) {
    HapticFeedback.lightImpact();
    final taskIndex = _allTasks.indexWhere((t) => t['id'] == taskId);
    if (taskIndex != -1) {
      setState(() {
        _allTasks[taskIndex]['status'] = 'failed';
        _allTasks[taskIndex]['errorMessage'] = 'Cancelled by user';
      });
      _filterTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task #$taskId cancelled'),
          backgroundColor: AppTheme.warningLight,
        ),
      );
    }
  }

  void _bulkAction(String action) {
    HapticFeedback.mediumImpact();

    for (String taskId in _selectedTasks) {
      switch (action) {
        case 'retry':
          _retryTask(taskId);
          break;
        case 'cancel':
          _cancelTask(taskId);
          break;
      }
    }

    setState(() {
      _isSelectionMode = false;
      _selectedTasks.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Task Monitoring',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: () => _bulkAction('retry'),
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.warningLight,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () => _bulkAction('cancel'),
              icon: CustomIconWidget(
                iconName: 'cancel',
                color: AppTheme.errorLight,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedTasks.clear();
                });
              },
              icon: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.textSecondaryLight,
                size: 24,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/main-dashboard'),
              icon: CustomIconWidget(
                iconName: 'dashboard',
                color: AppTheme.textPrimaryLight,
                size: 24,
              ),
            ),
          ],
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filter chips
            FilterChipsWidget(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
              filters: _filters,
            ),

            // Selection mode indicator
            if (_isSelectionMode)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                child: Text(
                  '${_selectedTasks.length} task${_selectedTasks.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),

            // Task list
            Expanded(
              child: _filteredTasks.isEmpty
                  ? EmptyStateWidget(
                      title: _selectedFilter == 'All'
                          ? 'No Tasks Found'
                          : 'No ${_selectedFilter} Tasks',
                      subtitle: _selectedFilter == 'All'
                          ? 'Your execution requests and system tasks will appear here once you start trading.'
                          : 'No tasks with ${_selectedFilter.toLowerCase()} status found. Try selecting a different filter.',
                      iconName: 'assignment',
                      onAction: () => Navigator.pushNamed(
                          context, '/execution-request-flow'),
                      actionText: 'Create New Request',
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshTasks,
                      color: AppTheme.primaryLight,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            _filteredTasks.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _filteredTasks.length) {
                            return Container(
                              padding: EdgeInsets.all(4.w),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            );
                          }

                          final task = _filteredTasks[index];
                          final taskId = task['id'] as String;

                          return TaskCardWidget(
                            task: task,
                            isSelected: _selectedTasks.contains(taskId),
                            onTap: () => _onTaskTap(taskId),
                            onLongPress: () => _onTaskLongPress(taskId),
                            onRetry: task['status'] == 'failed'
                                ? () => _retryTask(taskId)
                                : null,
                            onCancel: task['status'] == 'pending'
                                ? () => _cancelTask(taskId)
                                : null,
                            onViewDetails: () => _showTaskDetails(taskId),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/execution-request-flow'),
              backgroundColor: AppTheme.primaryLight,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }
}