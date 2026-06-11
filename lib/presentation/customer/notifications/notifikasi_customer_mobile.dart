import 'package:flutter/material.dart';

import '../../../core/services/notification_service_appwrite.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../data/models/notification_model.dart';

class NotifikasiCustomerMobile extends StatefulWidget {
  const NotifikasiCustomerMobile({super.key});

  @override
  State<NotifikasiCustomerMobile> createState() =>
      _NotifikasiCustomerMobileState();
}

class _NotifikasiCustomerMobileState
    extends State<NotifikasiCustomerMobile> {
  final NotificationServiceAppwrite _service =
      NotificationServiceAppwrite();
  late Future<List<NotificationModel>> _notifsFuture;

  @override
  void initState() {
    super.initState();
    _notifsFuture = _load();
  }

  void _refresh() {
    setState(() {
      _notifsFuture = _load();
    });
  }

  Future<List<NotificationModel>> _load() async {
    final account = await AuthServiceAppwrite().getCurrentUser();
    return _service.getNotifications(account.$id);
  }

  String _formatTime(String iso) {
    try {
      final date = DateTime.parse(iso);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
      if (diff.inHours < 24) return '${diff.inHours}j lalu';
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text('Notifikasi Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          FutureBuilder<List<NotificationModel>>(
            future: _notifsFuture,
            builder: (context, snapshot) {
              final hasUnread = snapshot.data?.any((n) => !n.isRead) ?? false;
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  final account =
                      await AuthServiceAppwrite().getCurrentUser();
                  await _service.markAllAsRead(account.$id);
                  _refresh();
                },
                child: const Text('Tandai Semua Dibaca'),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notifsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Gagal memuat notifikasi:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final notifs = snapshot.data ?? [];

          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi akan muncul di sini ketika ada perubahan status pesanan.',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                return _notifCard(notif);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _notifCard(NotificationModel notif) {
    return GestureDetector(
      onTap: () async {
        if (!notif.isRead) {
          await _service.markAsRead(notif.id);
          _refresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xffEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? Colors.grey.shade200
                : const Color(0xff2563EB).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead
                    ? Colors.grey.shade100
                    : const Color(0xffDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _notifIcon(notif.type),
                color: notif.isRead ? Colors.grey : const Color(0xff2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: notif.isRead
                                ? Colors.black54
                                : Colors.black,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xff2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      color:
                          notif.isRead ? Colors.grey : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.createdAt),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'status_update':
        return Icons.sync_alt;
      default:
        return Icons.notifications_outlined;
    }
  }
}
