import 'package:beespoke_ai/view/product_feed/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/prefrence_controller.dart';
import '../../controller/product_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routing/app_router.dart';
import '../shared/empty_view.dart';
import '../shared/error_view.dart';
import '../shared/loading_view.dart';

class ProductFeedScreen extends StatelessWidget {
  const ProductFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.find<ProductController>();
    final prefCtrl = Get.find<PreferenceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(prefCtrl),
      body: Column(
        children: [
          _SearchBar(controller: productCtrl),
          _CategoryChips(controller: productCtrl),
          Expanded(child: _FeedBody(controller: productCtrl)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(PreferenceController prefCtrl) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('StyleSwipe'),
        ],
      ),
      actions: [
        Obx(() => Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_rounded),
              color: AppColors.like,
              onPressed: () => Get.toNamed(AppRouter.preferences),
              tooltip: 'My Preferences',
            ),
            if (prefCtrl.likedCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.dislike,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${prefCtrl.likedCount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        )),
        // History icon
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: () => Get.toNamed(AppRouter.browsingHistory),
          tooltip: 'Browsing History',
        ),
      ],
    );
  }
}


class _SearchBar extends StatelessWidget {
  final ProductController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: AppStyles.bodyM,
        decoration: AppStyles.searchDecoration('Search products…'),
      ),
    );
  }
}


class _CategoryChips extends StatelessWidget {
  final ProductController controller;
  const _CategoryChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) return const SizedBox(height: 8);
      return SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = controller.categories[i];
            final selected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.selectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : null,
                ),
                child: Text(
                  _cap(cat),
                  style: AppStyles.bodyS.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}


class _FeedBody extends StatelessWidget {
  final ProductController controller;
  const _FeedBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.feedState.value) {
        case FeedState.loading:
          return const LoadingView();

        case FeedState.error:
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );

        case FeedState.empty:
          return const EmptyView(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            subtitle: 'Try a different category or search term.',
          );

        case FeedState.success:
          if (controller.displayedProducts.isEmpty) {
            return EmptyView(
              icon: Icons.manage_search_rounded,
              title: 'No results',
              subtitle: 'No products match "${controller.searchQuery.value}"',
              action: TextButton.icon(
                onPressed: controller.clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Clear search'),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refresh,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.67,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.displayedProducts.length,
              itemBuilder: (_, i) => Obx(() => ProductCard(
                product: controller.displayedProducts[i],
                index: i,
              )),
            ),
          );

        default:
          return const SizedBox.shrink();
      }
    });
  }
}