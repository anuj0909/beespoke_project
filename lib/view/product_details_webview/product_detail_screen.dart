import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controller/prefrence_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/routing/app_router.dart';
import '../../model/product.dart';


class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = Get.arguments as Product;
    final prefCtrl = Get.find<PreferenceController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(product, prefCtrl),
          SliverToBoxAdapter(
            child: _buildBody(product, prefCtrl),
          ),
        ],
      ),
    );
  }


  Widget _buildSliverAppBar(Product product, PreferenceController prefCtrl) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      actions: [
        Obx(() => GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            prefCtrl.like(product);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                prefCtrl.isLiked(product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                key: ValueKey(prefCtrl.isLiked(product.id)),
                color: prefCtrl.isLiked(product.id)
                    ? AppColors.like
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        )),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _ProductImage(imageUrl: product.image),
      ),
    );
  }


  Widget _buildBody(Product product, PreferenceController prefCtrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryPill(category: product.category)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.1),

          const SizedBox(height: 12),

          Text(
            product.title,
            style: AppStyles.headingM.copyWith(height: 1.4, fontSize: 20),
          ).animate(delay: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                product.formattedPrice,
                style: AppStyles.price.copyWith(fontSize: 28),
              ),
              const Spacer(),
              _RatingChip(rating: product.rating, count: product.ratingCount),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          _PreferenceRow(product: product, prefCtrl: prefCtrl)
              .animate(delay: 150.ms)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 20),

          Text('About this product', style: AppStyles.headingS)
              .animate(delay: 200.ms)
              .fadeIn(),

          const SizedBox(height: 10),

          Text(
            product.description,
            style: AppStyles.bodyM.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ).animate(delay: 220.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 28),

          _SpecsRow(product: product)
              .animate(delay: 260.ms)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: 32),

          _BrowserButton(product: product)
              .animate(delay: 300.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }
}


class _ProductImage extends StatelessWidget {
  final String imageUrl;
  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F8F8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _GridPainter()),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 80, 32, 24),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 0.5;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}


class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 10,
        ),
      ),
    );
  }
}


class _RatingChip extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingChip({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 18, color: AppColors.star),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: AppStyles.caption,
          ),
        ],
      ),
    );
  }
}


class _PreferenceRow extends StatelessWidget {
  final Product product;
  final PreferenceController prefCtrl;

  const _PreferenceRow({required this.product, required this.prefCtrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final liked = prefCtrl.isLiked(product.id);
            return _PrefActionButton(
              label: liked ? 'Saved!' : 'Save',
              icon: liked ? Icons.favorite : Icons.favorite_border,
              color: AppColors.like,
              isActive: liked,
              onTap: () {
                HapticFeedback.lightImpact();
                prefCtrl.like(product);
              },
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final disliked = prefCtrl.isDisliked(product.id);
            return _PrefActionButton(
              label: disliked ? 'Disliked' : 'Not for me',
              icon: disliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: AppColors.dislike,
              isActive: disliked,
              onTap: () {
                HapticFeedback.lightImpact();
                prefCtrl.dislike(product);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _PrefActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _PrefActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : color,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppStyles.bodyS.copyWith(
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SpecsRow extends StatelessWidget {
  final Product product;
  const _SpecsRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _SpecItem(
            icon: Icons.sell_outlined,
            label: 'Price',
            value: product.formattedPrice,
          ),
          _SpecDivider(),
          _SpecItem(
            icon: Icons.star_outline_rounded,
            label: 'Rating',
            value: '${product.rating}/5',
          ),
          _SpecDivider(),
          _SpecItem(
            icon: Icons.people_outline_rounded,
            label: 'Reviews',
            value: '${product.ratingCount}',
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppStyles.caption),
        ],
      ),
    );
  }
}

class _SpecDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 1,
      color: AppColors.border,
    );
  }
}


class _BrowserButton extends StatelessWidget {
  final Product product;
  const _BrowserButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(
              AppRouter.productWebview,
              arguments: product,
            ),
            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
            label: const Text('Shop Online'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: AppStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Feed'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: AppStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}