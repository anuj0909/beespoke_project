import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/routing/app_router.dart';

import '../../controller/prefrence_controller.dart';
import '../../model/prefrence.dart';
import '../../model/product.dart';
import 'like_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const ProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRouter.productDetail,
        arguments: product,
      ),
      child: Container(
        decoration: AppStyles.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFF8F8F8),
                    padding: const EdgeInsets.all(12),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 36,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: _CategoryBadge(category: product.category),
                  ),

                  Obx(() {
                    final ctrl = Get.find<PreferenceController>();
                    final pref = ctrl.getPreference(product.id);
                    if (pref == null) return const SizedBox.shrink();
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: _PreferenceBadge(type: pref),
                    );
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodyS.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _RatingRow(rating: product.rating, count: product.ratingCount),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.formattedPrice, style: AppStyles.priceSmall),
                      LikeDislikeButtons(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: 50 * (index % 8)))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.12, end: 0, curve: Curves.easeOut),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.88),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: AppStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PreferenceBadge extends StatelessWidget {
  final PreferenceType type;
  const _PreferenceBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isLiked = type == PreferenceType.liked;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isLiked ? AppColors.like : AppColors.dislike,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isLiked ? AppColors.like : AppColors.dislike)
                .withOpacity(0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(
        isLiked ? Icons.favorite : Icons.thumb_down,
        color: Colors.white,
        size: 10,
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingRow({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
        const SizedBox(width: 3),
        Text(
          '$rating',
          style:
          AppStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 3),
        Text(
          '($count)',
          style: AppStyles.caption,
        ),
      ],
    );
  }
}