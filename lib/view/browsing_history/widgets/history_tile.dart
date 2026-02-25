import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';
import '../../../model/browsing_history_item.dart';

class HistoryTile extends StatelessWidget {
  final BrowsingHistoryItem item;
  final VoidCallback? onDelete;

  const HistoryTile({
    super.key,
    required this.item,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: AppStyles.surfaceDecoration,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.language_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          item.pageTitle.isNotEmpty ? item.pageTitle : item.productTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              item.displayUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 2),
            Text(
              item.timeAgo,
              style: AppStyles.caption,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: onDelete != null
            ? IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.dislike, size: 20),
          onPressed: onDelete,
          splashRadius: 20,
        )
            : const Icon(Icons.chevron_right, color: AppColors.textHint),
      ),
    );
  }
}