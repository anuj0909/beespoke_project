import 'package:get/get.dart';
import '../../view/splash_screen/splash_Screen.dart';


class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String productFeed = '/feed';
  static const String productWebview = '/webview';
  static const String browsingHistory = '/history';
  static const String preferences = '/preferences';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: productFeed,
      page: () => const ProductFeedScreen(),
      binding: AppBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: productWebview,
      page: () => const ProductWebviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: browsingHistory,
      page: () => const BrowsingHistoryScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: preferences,
      page: () => const PreferencesScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}