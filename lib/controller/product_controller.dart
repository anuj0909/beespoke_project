import 'package:get/get.dart';
import '../core/services/api_service.dart';

import '../core/services/local_storage_services.dart';
import '../core/utils/logger.dart';
import '../model/product.dart';


enum FeedState { initial, loading, success, error, empty }

class ProductController extends GetxController {
  final _api = ApiService.instance;
  final _storage = LocalStorageService.instance;


  final feedState = FeedState.initial.obs;
  final allProducts = <Product>[].obs;
  final displayedProducts = <Product>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final errorMessage = ''.obs;
  final isOffline = false.obs;


  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
  }


  Future<void> fetchProducts({String? category}) async {
    feedState.value = FeedState.loading;
    errorMessage.value = '';
    isOffline.value = false;

    try {
      final List<dynamic> raw = category != null && category != 'All'
          ? await _api.getProductsByCategory(category)
          : await _api.getProducts();

      final products = raw
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      allProducts.value = products;
      _applyFilters();


      await _storage.cacheProducts(products.map((p) => p.toMap()).toList());

      feedState.value =
      products.isEmpty ? FeedState.empty : FeedState.success;
      AppLogger.i('Fetched ${products.length} products', tag: 'ProductController');
    } on ApiException catch (e) {
      AppLogger.e(e.message, error: e, tag: 'ProductController');
      await _loadFromCache();
    } catch (e, st) {
      AppLogger.e('Unexpected error', error: e, stackTrace: st,
          tag: 'ProductController');
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    final cached = await _storage.getCachedProducts();
    if (cached.isNotEmpty) {
      allProducts.value = cached.map(Product.fromMap).toList();
      _applyFilters();
      feedState.value = FeedState.success;
      isOffline.value = true;
      Get.snackbar(
        '📡 Offline Mode',
        'No internet. Showing cached data.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } else {
      feedState.value = FeedState.error;
      errorMessage.value = 'No internet connection and no cached data available.';
    }
  }

  Future<void> fetchCategories() async {
    try {
      final raw = await _api.getCategories();
      categories.value = ['All', ...raw.map((e) => e.toString())];
    } catch (_) {
      categories.value = ['All'];
    }
  }



  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchProducts(category: category);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.toLowerCase().trim();
    if (q.isEmpty) {
      displayedProducts.value = List.from(allProducts);
    } else {
      displayedProducts.value = allProducts.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }
  }


  Future<void> refresh() => fetchProducts(
    category: selectedCategory.value == 'All' ? null : selectedCategory.value,
  );

  Product? findById(int id) {
    try {
      return allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}