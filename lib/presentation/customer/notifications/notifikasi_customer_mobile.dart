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
  final ScrollController _scrollController = ScrollController();

  List<NotificationModel> _notifs = [];
  String? _cursor;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirst() async {
    setState(() {
      _isLoading = true;
      _cursor = null;
      _hasMore = true;
      _notifs = [];
    });

    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      _userId = account.$id;
      final response = await _service.getNotificationsPage(
        userId: account.$id,
        cursor: null,
        limit: 20,
      );
      _notifs = response.items;
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _userId == null) return;
    setState(() => _isLoadingMore = true);

    try {
      final response = await _service.getNotificationsPage(
        userId: _userId!,
        cursor: _cursor,
        limit: 20,
      );
      _notifs.addAll(response.items);
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _refresh() {
    _loadFirst();
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
          if (_notifs.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                if (_userId == null) return;
                await _service.markAllAsRead(_userId!);
                _refresh();
              },
              child: const Text('Tandai Semua Dibaca'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_notifs.isEmpty) {
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
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _notifs.length + (_hasMore || _isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _isLoadingMore
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(Icons.expand_more, size: 20),
                        label: const Text('Muat lebih banyak'),
                      ),
              ),
            );
          }
          return _notifCard(_notifs[index]);
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
