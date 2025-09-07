import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_button_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _currentLoadingText = 'Initializing OrbitFlash...';
  bool _showRetryButton = false;
  bool _showProgress = false;
  double _progress = 0.0;
  bool _isInitializing = true;

  final List<Map<String, dynamic>> _initializationSteps = [
    {
      'text': 'Checking wallet connection status...',
      'duration': 800,
      'progress': 0.2,
    },
    {
      'text': 'Loading cached opportunities...',
      'duration': 600,
      'progress': 0.4,
    },
    {
      'text': 'Verifying JWT tokens...',
      'duration': 700,
      'progress': 0.6,
    },
    {
      'text': 'Preparing WebSocket connections...',
      'duration': 900,
      'progress': 0.8,
    },
    {
      'text': 'Finalizing setup...',
      'duration': 500,
      'progress': 1.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setSystemUIOverlay();
    _startInitialization();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _startInitialization() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      setState(() {
        _showProgress = true;
      });

      for (int i = 0; i < _initializationSteps.length; i++) {
        final step = _initializationSteps[i];

        setState(() {
          _currentLoadingText = step['text'] as String;
          _progress = step['progress'] as double;
        });

        await Future.delayed(Duration(milliseconds: step['duration'] as int));
      }

      await _performSecureStorageInitialization();
      await _detectMockMode();
      await _handleDeepLinks();

      _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _performSecureStorageInitialization() async {
    // Simulate secure storage initialization
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _detectMockMode() async {
    // Simulate mock mode detection
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> _handleDeepLinks() async {
    // Simulate deep link handling
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _navigateToNextScreen() {
    // Simulate authentication state check
    final bool isAuthenticated = _checkAuthenticationState();
    final bool isFirstTime = _checkFirstTimeUser();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (isFirstTime) {
        // Navigate to onboarding (not implemented in this scope)
        Navigator.pushReplacementNamed(context, '/authentication-screen');
      } else if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/main-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/authentication-screen');
      }
    });
  }

  bool _checkAuthenticationState() {
    // Mock authentication check
    // In real implementation, this would check JWT tokens in secure storage
    return false;
  }

  bool _checkFirstTimeUser() {
    // Mock first time user check
    // In real implementation, this would check shared preferences
    return false;
  }

  void _handleInitializationError() {
    setState(() {
      _isInitializing = false;
      _showRetryButton = true;
      _currentLoadingText =
          'Connection timeout. Please check your internet connection.';
    });
  }

  void _retryInitialization() {
    setState(() {
      _showRetryButton = false;
      _isInitializing = true;
      _showProgress = false;
      _progress = 0.0;
      _currentLoadingText = 'Retrying initialization...';
    });

    _startInitialization();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackgroundWidget(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AnimatedLogoWidget(),
                        SizedBox(height: 4.h),
                        Text(
                          'OrbitFlash',
                          style: AppTheme.lightTheme.textTheme.headlineMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'DeFi Flash Loan Opportunities',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showRetryButton
                            ? RetryButtonWidget(
                                onRetry: _retryInitialization,
                                message: _currentLoadingText,
                              )
                            : _isInitializing
                                ? LoadingIndicatorWidget(
                                    loadingText: _currentLoadingText,
                                    showProgress: _showProgress,
                                    progress: _progress,
                                  )
                                : Container(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      'Secure • Fast • Reliable',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
