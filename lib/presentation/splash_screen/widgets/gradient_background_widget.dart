import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GradientBackgroundWidget extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.9),
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7),
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.6),
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.transparent,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
