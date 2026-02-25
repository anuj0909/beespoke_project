import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../core/services/local_storage_services.dart';
import '../core/utils/logger.dart';
import '../model/prefrence.dart';
import '../model/product.dart';


class PreferenceController extends GetxController {
  final _storage = LocalStorageService.instance;


  final _preferenceMap = <int, PreferenceType>{}.obs;
  final likedList = <Preference>[].obs;
  final dislikedList = <Preference>[].obs;


  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final rows = await _storage.getAllPreferences();
    final map = <int, PreferenceType>{};
    final liked = <Preference>[];
    final disliked = <Preference>[];

    for (final row in rows) {
      final pref = Preference.fromMap(row);
      map[pref.productId] = pref.type;
      if (pref.isLiked) {
        liked.add(pref);
      } else {
        disliked.add(pref);
      }
    }

    _preferenceMap.value = map;
    likedList.value = liked;
    dislikedList.value = disliked;
    AppLogger.i(
      'Loaded ${rows.length} preferences (liked: ${liked.length}, disliked: ${disliked.length})',
      tag: 'PreferenceController',
    );
  }



  PreferenceType? getPreference(int productId) => _preferenceMap[productId];
  bool isLiked(int productId) =>
      _preferenceMap[productId] == PreferenceType.liked;
  bool isDisliked(int productId) =>
      _preferenceMap[productId] == PreferenceType.disliked;
  bool hasPreference(int productId) => _preferenceMap.containsKey(productId);

  int get likedCount => likedList.length;
  int get dislikedCount => dislikedList.length;



  Future<void> like(Product product) async {
    if (isLiked(product.id)) {
      // Toggle off
      await _removePreference(product.id);
    } else {
      await _setPreference(product, PreferenceType.liked);
      _showToast('Added to Liked');
    }
  }

  Future<void> dislike(Product product) async {
    if (isDisliked(product.id)) {
      // Toggle off
      await _removePreference(product.id);
    } else {
      await _setPreference(product, PreferenceType.disliked);
      _showToast('Added to Disliked');
    }
  }

  Future<void> removePreference(int productId) async {
    await _removePreference(productId);
  }



  Future<void> _setPreference(Product product, PreferenceType type) async {
    final pref = Preference(
      productId: product.id,
      productTitle: product.title,
      productImage: product.image,
      productPrice: product.price,
      type: type,
      createdAt: DateTime.now(),
    );

    await _storage.upsertPreference(pref.toMap());
    _preferenceMap[product.id] = type;


    likedList.removeWhere((p) => p.productId == product.id);
    dislikedList.removeWhere((p) => p.productId == product.id);

    if (type == PreferenceType.liked) {
      likedList.insert(0, pref);
    } else {
      dislikedList.insert(0, pref);
    }

    AppLogger.d(
      'Set preference: product=${product.id} type=${type.label}',
      tag: 'PreferenceController',
    );
  }

  Future<void> _removePreference(int productId) async {
    await _storage.removePreference(productId);
    _preferenceMap.remove(productId);
    likedList.removeWhere((p) => p.productId == productId);
    dislikedList.removeWhere((p) => p.productId == productId);
    AppLogger.d('Removed preference: product=$productId',
        tag: 'PreferenceController');
  }

  void _showToast(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }
}