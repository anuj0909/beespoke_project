import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../controller/browser_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routing/app_router.dart';
import '../../model/product.dart';

class ProductWebviewScreen extends StatefulWidget {
  const ProductWebviewScreen({super.key});

  @override
  State<ProductWebviewScreen> createState() => _ProductWebviewScreenState();
}

class _ProductWebviewScreenState extends State<ProductWebviewScreen> {
  late final BrowserController _browserCtrl;
  late final Product _product;

  @override
  void initState() {
    super.initState();
    _browserCtrl = Get.find<BrowserController>();
    _product = Get.arguments as Product;

    _browserCtrl.initWebView(
      url: _product.shopUrl,
      productId: _product.id,
      productTitle: _product.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: 40,
      titleSpacing: 0,
      title: Obx(() => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _browserCtrl.currentPageTitle.value.isNotEmpty
                  ? _browserCtrl.currentPageTitle.value
                  : _product.title,
              style: AppStyles.bodyS.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _browserCtrl.currentUrl.value.isNotEmpty
                  ? _browserCtrl.currentUrl.value
                  : _product.shopUrl,
              style: AppStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      )),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: () => Get.toNamed(AppRouter.browsingHistory),
          tooltip: 'History',
        ),
      ],
    );
  }


  Widget _buildBody() {
    return Column(
      children: [
        Obx(() => _browserCtrl.isLoading.value
            ? LinearProgressIndicator(
          value: _browserCtrl.loadingProgress.value / 100,
          backgroundColor: AppColors.border,
          color: AppColors.primary,
          minHeight: 3,
        )
            : const SizedBox(height: 3)),

        Expanded(
          child: Obx(() {
            if (!_browserCtrl.isWebViewReady.value ||
                _browserCtrl.webViewController == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return WebViewWidget(
              controller: _browserCtrl.webViewController!,
            );
          }),
        ),
      ],
    );
  }


  Widget _buildBottomBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          Obx(() => _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: _browserCtrl.canGoBack.value
                ? _browserCtrl.goBack
                : null,
          )),
          Obx(() => _NavBtn(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: _browserCtrl.canGoForward.value
                ? _browserCtrl.goForward
                : null,
          )),
          _NavBtn(icon: Icons.refresh_rounded, onTap: _browserCtrl.reload),
          Obx(() => _browserCtrl.isLoading.value
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
              : _NavBtn(
            icon: Icons.history_rounded,
            onTap: () => Get.toNamed(AppRouter.browsingHistory),
          )),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      color: onTap != null ? AppColors.textPrimary : AppColors.textHint,
      splashRadius: 22,
    );
  }
}