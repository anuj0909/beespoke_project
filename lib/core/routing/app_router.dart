import 'package:get/get.dart';
import '../../view/browsing_history/browsing_history_screen.dart';
import '../../view/prefrences/prefrences_screen.dart';
import '../../view/product_details_webview/product_detail_screen.dart';
import '../../view/product_details_webview/product_webview_screen.dart';
import '../../view/product_feed/product_feed_screen.dart';
import '../../view/splash_screen/splash_Screen.dart';

import '../bindings/app_binding.dart';

class AppRouter {
  AppRouter._();

  static const String splash        = '/';
  static const String productFeed   = '/feed';
  static const String productDetail = '/detail';
  static const String productWebview = '/webview';
  static const String browsingHistory = '/history';
  static const String preferences   = '/preferences';

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
      name: productDetail,
      page: () => const ProductDetailScreen(),
      transition: Transition.rightToLeft,
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