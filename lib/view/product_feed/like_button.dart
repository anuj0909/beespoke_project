import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
// import '../../../controllers/preference_controller.dart';
import '../../../core/constants/app_colors.dart';
// import '../../../models/product.dart';
import '../../controller/prefrence_controller.dart';
import '../../model/product.dart';

class LikeDislikeButtons extends StatelessWidget {
  final Product product;
  final bool compact;

  const LikeDislikeButtons({
    super.key,
    required this.product,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PreferenceController>();

    return Obx(() {
      final liked = ctrl.isLiked(product.id);
      final disliked = ctrl.isDisliked(product.id);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrefButton(
            icon: disliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            color: AppColors.dislike,
            bgColor: AppColors.dislikeLight,
            isActive: disliked,
            compact: compact,
            onTap: () {
              HapticFeedback.lightImpact();
              ctrl.dislike(product);
            },
          ),
          SizedBox(width: compact ? 6 : 10),
          _PrefButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            color: AppColors.like,
            bgColor: AppColors.likeLight,
            isActive: liked,
            compact: compact,
            onTap: () {
              HapticFeedback.lightImpact();
              ctrl.like(product);
            },
          ),
        ],
      );
    });
  }
}

class _PrefButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;

  const _PrefButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isActive,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 30.0 : 44.0;
    final iconSize = compact ? 15.0 : 22.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isActive ? color : Colors.grey.shade400,
        ),
      ).animate(key: ValueKey(isActive)).then().shimmer(
        duration: isActive ? 400.ms : 0.ms,
        color: color.withOpacity(0.3),
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final Product product;

  const LikeButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<PreferenceController>();

    return Obx(() {
      final liked = ctrl.isLiked(product.id);
      return IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          ctrl.like(product);
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(liked),
            color: liked ? AppColors.like : null,
            size: 26,
          ),
        ),
      );
    });
  }
}