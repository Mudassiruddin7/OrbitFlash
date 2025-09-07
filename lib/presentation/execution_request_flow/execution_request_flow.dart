import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/authentication_widget.dart';
import './widgets/confirmation_details_widget.dart';
import './widgets/opportunity_summary_widget.dart';
import './widgets/parameter_input_widget.dart';
import './widgets/step_indicator_widget.dart';
import './widgets/success_feedback_widget.dart';

class ExecutionRequestFlow extends StatefulWidget {
  const ExecutionRequestFlow({Key? key}) : super(key: key);

  @override
  State<ExecutionRequestFlow> createState() => _ExecutionRequestFlowState();
}

class _ExecutionRequestFlowState extends State<ExecutionRequestFlow>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int currentStep = 0;
  bool isLoading = false;
  bool showSuccess = false;
  String requestId = '';

  // Controllers for input fields
  late TextEditingController _amountController;
  late TextEditingController _slippageController;
  late TextEditingController _gasController;

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Mock opportunity data
  final Map<String, dynamic> mockOpportunity = {
    'id': 'OP_001',
    'protocol': 'Uniswap V3',
    'tokenPair': 'ETH/USDC',
    'dex': 'Uniswap V3',
    'profitPercent': '2.45',
    'profitEstimate': '1,245.67',
    'requiredAmount': '50,000',
    'gasEstimate': '0.025',
    'timeWindow': '45',
    'timestamp': DateTime.now().subtract(Duration(minutes: 2)),
  };

  final List<String> stepTitles = [
    'Parameters',
    'Confirmation',
    'Authentication',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _amountController = TextEditingController(text: '50000');
    _slippageController = TextEditingController(text: '0.5');
    _gasController = TextEditingController(text: '25.0');
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _amountController.dispose();
    _slippageController.dispose();
    _gasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: showSuccess ? _buildSuccessView() : _buildFlowView(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(6.w),
      child: SuccessFeedbackWidget(
        requestId: requestId,
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildFlowView() {
    return Column(
      children: [
        _buildHeader(),
        StepIndicatorWidget(
          currentStep: currentStep,
          totalSteps: stepTitles.length,
          stepTitles: stepTitles,
        ),
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: _buildCurrentStepContent(),
              ),
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _handleBackAction(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back_ios',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Execution Request',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 0:
        return _buildParametersStep();
      case 1:
        return _buildConfirmationStep();
      case 2:
        return _buildAuthenticationStep();
      default:
        return Container();
    }
  }

  Widget _buildParametersStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OpportunitySummaryWidget(opportunity: mockOpportunity),
        SizedBox(height: 3.h),
        ParameterInputWidget(
          amountController: _amountController,
          slippageController: _slippageController,
          gasController: _gasController,
          onAmountChanged: (value) => setState(() {}),
          onSlippageChanged: (value) => setState(() {}),
          onGasChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return ConfirmationDetailsWidget(
      opportunity: mockOpportunity,
      amount: _amountController.text,
      slippage: _slippageController.text,
      gasPrice: _gasController.text,
    );
  }

  Widget _buildAuthenticationStep() {
    return AuthenticationWidget(
      onBiometricAuth: _handleBiometricAuth,
      onWalletAuth: _handleWalletAuth,
      isBiometricAvailable: true,
      isLoading: isLoading,
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _handlePreviousStep,
                child: Text('Back'),
              ),
            ),
            SizedBox(width: 4.w),
          ],
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleNextStep,
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_getButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (currentStep) {
      case 0:
        return 'Continue';
      case 1:
        return 'Confirm';
      case 2:
        return 'Submit';
      default:
        return 'Next';
    }
  }

  void _handleBackAction() {
    if (currentStep > 0) {
      _handlePreviousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handlePreviousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _animateStepTransition();
    }
  }

  void _handleNextStep() {
    if (_validateCurrentStep()) {
      if (currentStep < stepTitles.length - 1) {
        setState(() {
          currentStep++;
        });
        _animateStepTransition();
      } else {
        // This is the final step, handle submission
        _handleSubmission();
      }
    }
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return _validateParameters();
      case 1:
        return true; // Confirmation step doesn't need validation
      case 2:
        return true; // Authentication will be handled separately
      default:
        return true;
    }
  }

  bool _validateParameters() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    final slippage = double.tryParse(_slippageController.text);
    final gas = double.tryParse(_gasController.text);

    if (amount == null || amount < 1000 || amount > 1000000) {
      _showErrorMessage(
          'Please enter a valid amount between \$1,000 and \$1,000,000');
      return false;
    }

    if (slippage == null || slippage < 0.1 || slippage > 10) {
      _showErrorMessage('Please enter a valid slippage between 0.1% and 10%');
      return false;
    }

    if (gas == null || gas < 1 || gas > 500) {
      _showErrorMessage(
          'Please enter a valid gas price between 1 and 500 Gwei');
      return false;
    }

    return true;
  }

  void _animateStepTransition() {
    _slideController.reset();
    _slideController.forward();
  }

  void _handleBiometricAuth() {
    _performAuthentication('biometric');
  }

  void _handleWalletAuth() {
    _performAuthentication('wallet');
  }

  void _performAuthentication(String method) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate authentication process
      await Future.delayed(Duration(seconds: 2));

      // Mock successful authentication
      _handleSubmission();
    } catch (e) {
      _showErrorMessage('Authentication failed. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleSubmission() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate API call to submit execution request
      await Future.delayed(Duration(seconds: 2));

      // Generate mock request ID
      requestId =
          'REQ_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      setState(() {
        showSuccess = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorMessage('Failed to submit request. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
