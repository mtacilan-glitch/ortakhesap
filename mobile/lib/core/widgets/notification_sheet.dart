import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    if (isWide) {
      // Desktop / Web wide layout: Show as a side panel or custom dialog at the top right
      return showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Bildirimler Kapat',
        barrierColor: Colors.black.withOpacity(0.2),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 80, right: 32),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 380,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const NotificationSheet(),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim1, child: child),
          );
        },
      );
    } else {
      // Mobile layout: Show as a Bottom Sheet
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const NotificationSheet(),
          );
        },
      );
    }
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  // Use a local copy of mock notifications so we can manipulate read status or clear them
  late List<NotificationModel> _localNotifications;

  @override
  void initState() {
    super.initState();
    _localNotifications = List.from(MockData.notifications);
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _localNotifications.length; i++) {
        final n = _localNotifications[i];
        _localNotifications[i] = NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
    });
  }

  void _dismissNotification(int index) {
    setState(() {
      _localNotifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bildirimler',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_localNotifications.any((n) => !n.isRead))
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Hepsini Okundu İşaretle',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEF6)),

        // Notification List
        Expanded(
          child: _localNotifications.isEmpty
              ? _buildEmptyNotifications()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  itemCount: _localNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _localNotifications[index];
                    return _buildNotificationItem(notification, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case 'EXPENSE_ADDED':
        iconBg = const Color(0xFFFFF2EC);
        iconColor = const Color(0xFFFF6B2C);
        iconData = Icons.receipt_long_rounded;
        break;
      case 'PAYMENT_REMINDER':
        iconBg = const Color(0xFFEBF3FF);
        iconColor = const Color(0xFF2C84FF);
        iconData = Icons.notifications_active_rounded;
        break;
      case 'PAYMENT_RECEIVED':
        iconBg = const Color(0xFFEEFBF3);
        iconColor = const Color(0xFF10B981);
        iconData = Icons.check_circle_rounded;
        break;
      case 'GROUP_INVITE':
      default:
        iconBg = const Color(0xFFF3EEFF);
        iconColor = const Color(0xFF8B5CF6);
        iconData = Icons.group_add_rounded;
        break;
    }

    // Time difference calculation
    final diff = DateTime.now().difference(notification.createdAt);
    String timeText;
    if (diff.inMinutes < 60) {
      timeText = '${diff.inMinutes} dk. önce';
    } else if (diff.inHours < 24) {
      timeText = '${diff.inHours} saat önce';
    } else {
      timeText = '${diff.inDays} gün önce';
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _dismissNotification(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 20),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                timeText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary.withOpacity(0.8),
            ),
            child: Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: () {
            // Mark as read locally on tap
            setState(() {
              _localNotifications[index] = NotificationModel(
                id: notification.id,
                title: notification.title,
                body: notification.body,
                type: notification.type,
                isRead: true,
                createdAt: notification.createdAt,
              );
            });

            // Route dynamically depending on notification type
            Navigator.of(context).pop();
            if (notification.type == 'EXPENSE_ADDED') {
              context.push('/expenses');
            } else if (notification.type == 'PAYMENT_REMINDER' || notification.type == 'PAYMENT_RECEIVED') {
              context.push('/payments');
            } else if (notification.type == 'GROUP_INVITE') {
              context.push('/groups');
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'Bildirim Bulunmuyor',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Harika! Okunmamış bir bildiriminiz yok.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
