import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/prefrence_controller.dart';
import '../../controller/product_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routing/app_router.dart';
import '../../model/prefrence.dart';

import '../shared/empty_view.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefCtrl = Get.find<PreferenceController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Preferences'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelStyle:
              AppStyles.bodyS.copyWith(fontWeight: FontWeight.w600),
              tabs: [
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 16,
                          color: AppColors.like),
                      const SizedBox(width: 6),
                      Text('Liked (${prefCtrl.likedCount})'),
                    ],
                  ),
                )),
                Obx(() => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.thumb_down, size: 16,
                          color: AppColors.dislike),
                      const SizedBox(width: 6),
                      Text('Disliked (${prefCtrl.dislikedCount})'),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _PrefList(
              type: PreferenceType.liked,
              prefCtrl: prefCtrl,
            ),
            _PrefList(
              type: PreferenceType.disliked,
              prefCtrl: prefCtrl,
            ),
          ],
        ),
      ),
    );
  }
}


class _PrefList extends StatelessWidget {
  final PreferenceType type;
  final PreferenceController prefCtrl;

  const _PrefList({required this.type, required this.prefCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = type == PreferenceType.liked
          ? prefCtrl.likedList
          : prefCtrl.dislikedList;

      if (items.isEmpty) {
        return EmptyView(
          icon: type == PreferenceType.liked
              ? Icons.favorite_border
              : Icons.thumb_down_outlined,
          title: type == PreferenceType.liked
              ? 'Nothing liked yet'
              : 'Nothing disliked yet',
          subtitle: 'Rate products in the feed to see them here.',
          action: ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.storefront_rounded, size: 16),
            label: const Text('Browse Feed'),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _PrefCard(
          pref: items[i],
          prefCtrl: prefCtrl,
        ),
      );
    });
  }
}


class _PrefCard extends StatelessWidget {
  final Preference pref;
  final PreferenceController prefCtrl;

  const _PrefCard({required this.pref, required this.prefCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final productCtrl = Get.find<ProductController>();
            final product = productCtrl.findById(pref.productId);
            if (product != null) {
              Get.toNamed(
                AppRouter.productWebview,
                arguments: {'product': product},
              );
            } else {
              Get.snackbar(
                'Info',
                'Product details not available offline',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: pref.productImage,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pref.productTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodyS.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pref.formattedPrice,
                        style: AppStyles.priceSmall,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    pref.isLiked ? Icons.favorite : Icons.thumb_down,
                    color: pref.isLiked
                        ? AppColors.like
                        : AppColors.dislike,
                    size: 22,
                  ),
                  onPressed: () =>
                      prefCtrl.removePreference(pref.productId),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}