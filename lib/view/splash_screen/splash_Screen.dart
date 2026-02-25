import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routing/app_router.dart';

import '../../core/services/local_storage_services.dart';
import '../../core/utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    AppLogger.i('SplashScreen: initialising app', tag: 'SplashScreen');

    await LocalStorageService.instance.database;

    await Future.delayed(const Duration(milliseconds: 2200));
    Get.offAllNamed(AppRouter.productFeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                begin: const Offset(0.6, 0.6),
                curve: Curves.elasticOut,
                duration: 800.ms,
              ),

              const SizedBox(height: 28),

              Text(
                'StyleSwipe',
                style: AppStyles.headingXL.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                  letterSpacing: 1,
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 10),

              Text(
                'Discover your style',
                style: AppStyles.bodyL.copyWith(
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w400,
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 60),

              SizedBox(
                width: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                    minHeight: 3,
                  ),
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}