import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/app_styles.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const StyleSwipeApp());
}

class StyleSwipeApp extends StatelessWidget {
  const StyleSwipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StyleSwipe',
      debugShowCheckedModeBanner: false,
      theme: AppStyles.theme,
      initialRoute: AppRouter.splash,
      getPages: AppRouter.pages,
      defaultTransition: Transition.cupertino,
      // Global snackbar settings
      
    );
  }
}