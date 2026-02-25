import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/browser_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../shared/empty_view.dart';
import 'widgets/history_tile.dart';

class BrowsingHistoryScreen extends StatelessWidget {
  const BrowsingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BrowserController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browsing History'),
        actions: [
          Obx(() => ctrl.historyItems.isNotEmpty
              ? TextButton.icon(
            onPressed: () => _confirmClear(context, ctrl),
            icon: const Icon(Icons.delete_sweep_rounded,
                color: AppColors.dislike, size: 20),
            label: Text(
              'Clear All',
              style: AppStyles.bodyS
                  .copyWith(color: AppColors.dislike),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (ctrl.historyItems.isEmpty) {
          return const EmptyView(
            icon: Icons.history_toggle_off_rounded,
            title: 'No history yet',
            subtitle:
            'Pages you view in the in-app browser\nwill appear here.',
          );
        }

        return Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${ctrl.historyItems.length} visited',
                    style: AppStyles.labelM,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: ctrl.historyItems.length,
                itemBuilder: (_, i) {
                  final item = ctrl.historyItems[i];
                  return Dismissible(
                    key: Key('history_${item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dislike,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_rounded,
                          color: Colors.white),
                    ),
                    onDismissed: (_) {
                      if (item.id != null) ctrl.deleteHistoryItem(item.id!);
                    },
                    child: HistoryTile(
                      item: item,
                      onDelete: item.id != null
                          ? () => ctrl.deleteHistoryItem(item.id!)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _confirmClear(BuildContext context, BrowserController ctrl) {
    Get.defaultDialog(
      title: 'Clear History',
      middleText:
      'This will permanently delete all browsing history.',
      textCancel: 'Cancel',
      textConfirm: 'Clear All',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.dislike,
      onConfirm: () {
        ctrl.clearAllHistory();
        Get.back();
      },
    );
  }
}