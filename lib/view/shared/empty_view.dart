import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppStyles.headingM,
              textAlign: TextAlign.center,
            ).animate(delay: 100.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style:
              AppStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate(delay: 150.ms).fadeIn(),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!.animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}