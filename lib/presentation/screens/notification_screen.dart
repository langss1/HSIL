import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/spacing_constants.dart';
import '../../core/themes/color_palette.dart';
import '../providers/auth_controller.dart';
import '../providers/notification_provider.dart';
import '../widgets/glass_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthController>().user?.userId;
      if (userId != null) {
        context.read<NotificationProvider>().loadNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final userId = context.read<AuthController>().user?.userId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text('Notifikasi', style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (provider.hasUnread && userId != null)
            TextButton(
              onPressed: () => provider.markAllAsRead(userId),
              child: const Text('Tandai Dibaca', style: TextStyle(color: AppColors.safetyOrange)),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)))
              : provider.notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildList(provider, userId),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: Spacing.md),
          const Text('Belum ada notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Notifikasi terbaru akan muncul di sini', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildList(NotificationProvider provider, String? userId) {
    final groups = provider.groupedNotifications;
    final formatter = DateFormat('HH:mm');

    return ListView.builder(
      padding: Spacing.screenPadding,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final groupName = groups.keys.elementAt(index);
        final items = groups[groupName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Text(
                groupName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            ...items.map((n) {
              IconData icon = Icons.info_rounded;
              Color color = AppColors.info;
              if (n.type == 'reminder') {
                icon = Icons.alarm_rounded;
                color = AppColors.safetyOrange;
              } else if (n.type == 'success') {
                icon = Icons.check_circle_rounded;
                color = AppColors.success;
              } else if (n.type == 'failure') {
                icon = Icons.error_rounded;
                color = AppColors.error;
              } else if (n.type == 'broadcast') {
                icon = Icons.campaign_rounded;
                color = Colors.blueAccent;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: GlassCard(
                  onTap: () {
                    if (!n.isRead && userId != null) {
                      provider.markAsRead(userId, n.id);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: TextStyle(
                                fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.body,
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              groupName == 'Hari Ini' ? formatter.format(n.timestamp) : DateFormat('dd MMM yyyy, HH:mm').format(n.timestamp),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: AppColors.info, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: Spacing.md),
          ],
        );
      },
    );
  }
}
