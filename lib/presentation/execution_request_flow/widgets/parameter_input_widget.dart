import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParameterInputWidget extends StatefulWidget {
  final TextEditingController amountController;
  final TextEditingController slippageController;
  final TextEditingController gasController;
  final Function(String) onAmountChanged;
  final Function(String) onSlippageChanged;
  final Function(String) onGasChanged;

  const ParameterInputWidget({
    Key? key,
    required this.amountController,
    required this.slippageController,
    required this.gasController,
    required this.onAmountChanged,
    required this.onSlippageChanged,
    required this.onGasChanged,
  }) : super(key: key);

  @override
  State<ParameterInputWidget> createState() => _ParameterInputWidgetState();
}

class _ParameterInputWidgetState extends State<ParameterInputWidget> {
  String? amountError;
  String? slippageError;
  String? gasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Parameters',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildAmountInput(),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(child: _buildSlippageInput()),
            SizedBox(width: 4.w),
            Expanded(child: _buildGasInput()),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (USD)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '50,000.00',
            prefixIcon: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                '\$',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            errorText: amountError,
            suffixIcon: widget.amountController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.amountController.clear();
                      widget.onAmountChanged('');
                      _validateAmount('');
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            widget.onAmountChanged(value);
            _validateAmount(value);
          },
        ),
      ],
    );
  }

  Widget _buildSlippageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slippage',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.slippageController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.5',
            suffixText: '%',
            errorText: slippageError,
          ),
          onChanged: (value) {
            widget.onSlippageChanged(value);
            _validateSlippage(value);
          },
        ),
      ],
    );
  }

  Widget _buildGasInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gas Price',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.gasController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
          ],
          decoration: InputDecoration(
            hintText: '25.0',
            suffixText: 'Gwei',
            errorText: gasError,
          ),
          onChanged: (value) {
            widget.onGasChanged(value);
            _validateGas(value);
          },
        ),
      ],
    );
  }

  void _validateAmount(String value) {
    setState(() {
      if (value.isEmpty) {
        amountError = 'Amount is required';
      } else {
        final amount = double.tryParse(value.replaceAll(',', ''));
        if (amount == null) {
          amountError = 'Invalid amount format';
        } else if (amount < 1000) {
          amountError = 'Minimum amount is \$1,000';
        } else if (amount > 1000000) {
          amountError = 'Maximum amount is \$1,000,000';
        } else {
          amountError = null;
        }
      }
    });
  }

  void _validateSlippage(String value) {
    setState(() {
      if (value.isEmpty) {
        slippageError = 'Slippage is required';
      } else {
        final slippage = double.tryParse(value);
        if (slippage == null) {
          slippageError = 'Invalid slippage format';
        } else if (slippage < 0.1) {
          slippageError = 'Minimum 0.1%';
        } else if (slippage > 10) {
          slippageError = 'Maximum 10%';
        } else {
          slippageError = null;
        }
      }
    });
  }

  void _validateGas(String value) {
    setState(() {
      if (value.isEmpty) {
        gasError = 'Gas price is required';
      } else {
        final gas = double.tryParse(value);
        if (gas == null) {
          gasError = 'Invalid gas format';
        } else if (gas < 1) {
          gasError = 'Minimum 1 Gwei';
        } else if (gas > 500) {
          gasError = 'Maximum 500 Gwei';
        } else {
          gasError = null;
        }
      }
    });
  }

  bool get isValid =>
      amountError == null && slippageError == null && gasError == null;
}
