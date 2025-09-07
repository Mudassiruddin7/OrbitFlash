import 'package:flutter/material.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/subscription_management_screen/subscription_management_screen.dart';
import '../presentation/execution_request_flow/execution_request_flow.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/task_monitoring_screen/task_monitoring_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/opportunity_details_modal/opportunity_details_modal.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String mainDashboard = '/main-dashboard';
  static const String subscriptionManagement =
      '/subscription-management-screen';
  static const String executionRequestFlow = '/execution-request-flow';
  static const String splash = '/splash-screen';
  static const String authentication = '/authentication-screen';
  static const String taskMonitoring = '/task-monitoring-screen';
  static const String settingsScreen = '/settings-screen';
  static const String opportunityDetailsModal = '/opportunity-details-modal';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    mainDashboard: (context) => const MainDashboard(),
    subscriptionManagement: (context) => const SubscriptionManagementScreen(),
    executionRequestFlow: (context) => const ExecutionRequestFlow(),
    splash: (context) => const SplashScreen(),
    authentication: (context) => const AuthenticationScreen(),
    taskMonitoring: (context) => const TaskMonitoringScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    opportunityDetailsModal: (context) => const OpportunityDetailsModal(),
    // TODO: Add your other routes here
  };
}
