

import 'dart:ui';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/services/local_storage_services.dart';
import '../core/utils/logger.dart';
import '../model/browsing_history_item.dart';


class BrowserController extends GetxController {
  final _storage = LocalStorageService.instance;


  WebViewController? webViewController;

  final isWebViewReady = false.obs;
  final isLoading = false.obs;
  final loadingProgress = 0.obs;
  final currentUrl = ''.obs;
  final currentPageTitle = ''.obs;
  final canGoBack = false.obs;
  final canGoForward = false.obs;


  final historyItems = <BrowsingHistoryItem>[].obs;


  int _activeProductId = 0;
  String _activeProductTitle = '';


  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }


  void initWebView({
    required String url,
    required int productId,
    required String productTitle,
  }) {
    _activeProductId = productId;
    _activeProductTitle = productTitle;
    currentUrl.value = url;
    currentPageTitle.value = productTitle;

    isWebViewReady.value = false;

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _onPageStarted,
          onProgress: _onProgress,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(Uri.parse(url));


    isWebViewReady.value = true;
    AppLogger.i('WebView initialised for $url', tag: 'BrowserController');
  }

  void _onPageStarted(String url) {
    isLoading.value = true;
    loadingProgress.value = 0;
    currentUrl.value = url;
    AppLogger.d('Page started: $url', tag: 'BrowserController');
  }

  void _onProgress(int progress) {
    loadingProgress.value = progress;
  }

  Future<void> _onPageFinished(String url) async {
    isLoading.value = false;
    loadingProgress.value = 100;
    currentUrl.value = url;


    try {
      final titleResult = await webViewController
          ?.runJavaScriptReturningResult('document.title');
      final title =
          titleResult?.toString().replaceAll('"', '').trim() ?? '';
      currentPageTitle.value =
      title.isNotEmpty ? title : _activeProductTitle;
    } catch (_) {
      currentPageTitle.value = _activeProductTitle;
    }


    canGoBack.value = await webViewController?.canGoBack() ?? false;
    canGoForward.value = await webViewController?.canGoForward() ?? false;


    await _recordHistory(url);

    AppLogger.d('Page finished: $url', tag: 'BrowserController');
  }

  void _onWebResourceError(WebResourceError error) {
    isLoading.value = false;
    AppLogger.e(
      'WebView error: ${error.description}',
      tag: 'BrowserController',
    );
    Get.snackbar(
      'Error',
      'Failed to load page',
      snackPosition: SnackPosition.BOTTOM,
    );
  }



  void goBack() => webViewController?.goBack();
  void goForward() => webViewController?.goForward();
  void reload() => webViewController?.reload();


  Future<void> loadHistory() async {
    final rows = await _storage.getAllHistory();
    historyItems.value = rows.map(BrowsingHistoryItem.fromMap).toList();
    AppLogger.i('Loaded ${historyItems.length} history items',
        tag: 'BrowserController');
  }

  Future<void> _recordHistory(String url) async {
    final item = BrowsingHistoryItem(
      url: url,
      pageTitle: currentPageTitle.value,
      productId: _activeProductId,
      productTitle: _activeProductTitle,
      visitedAt: DateTime.now(),
    );

    final id = await _storage.insertHistory(item.toMap());
    final saved = BrowsingHistoryItem(
      id: id,
      url: url,
      pageTitle: item.pageTitle,
      productId: item.productId,
      productTitle: item.productTitle,
      visitedAt: item.visitedAt,
    );

    historyItems.insert(0, saved);
  }

  Future<void> deleteHistoryItem(int id) async {
    await _storage.deleteHistoryItem(id);
    historyItems.removeWhere((h) => h.id == id);
  }

  Future<void> clearAllHistory() async {
    await _storage.clearHistory();
    historyItems.clear();
    AppLogger.i('Cleared browsing history', tag: 'BrowserController');
  }
}