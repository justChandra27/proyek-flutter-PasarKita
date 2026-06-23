import 'package:flutter/material.dart';

import '../../../../core/services/notification_service_appwrite.dart';
import '../../../../core/services/auth_service_appwrite.dart';
import '../../../../data/models/notification_model.dart';

class NotificationsMobilePage extends StatefulWidget {
  final VoidCallback? onUnreadChanged;

  const NotificationsMobilePage({super.key, this.onUnreadChanged});

  @override
  State<NotificationsMobilePage> createState() =>
      _NotificationsMobilePageState();
}

class _NotificationsMobilePageState extends State<NotificationsMobilePage> {
  final NotificationServiceAppwrite _notificationService =
      NotificationServiceAppwrite();
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  final TextEditingController _searchController = TextEditingController();

  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'Semua';
  String _adminId = '';
  bool _markingAll = false;

  static const _filterOptions = [
    'Semua',
    'Belum Dibaca',
    'Sudah Dibaca',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final adminData = await _authService.getCurrentUserData();
      if (adminData == null) {
        if (!mounted) return;
        setState(() {
          _error = 'Gagal mendapatkan data pengguna';
          _loading = false;
        });
        return;
      }
      final uid = adminData['uid'] as String? ?? '';
      if (uid.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'ID pengguna tidak ditemukan';
          _loading = false;
        });
        return;
      }

      _adminId = uid;
      final notifications =
          await _notificationService.getNotifications(uid);

      if (!mounted) return;
      setState(() {
        _allNotifications = notifications;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredNotifications = _allNotifications.where((n) {
        if (_selectedFilter == 'Belum Dibaca' && n.isRead) return false;
        if (_selectedFilter == 'Sudah Dibaca' && !n.isRead) return false;
        if (query.isNotEmpty) {
          final title = n.title.toLowerCase();
          final message = n.message.toLowerCase();
          if (!title.contains(query) && !message.contains(query)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      await _notificationService.markAsRead(notification.id);
      if (!mounted) return;
      setState(() {
        final idx = _allNotifications.indexWhere((n) => n.id == notification.id);
        if (idx != -1) {
          _allNotifications[idx] = NotificationModel(
            id: _allNotifications[idx].id,
            userId: _allNotifications[idx].userId,
            title: _allNotifications[idx].title,
            message: _allNotifications[idx].message,
            type: _allNotifications[idx].type,
            orderId: _allNotifications[idx].orderId,
            isRead: true,
            createdAt: _allNotifications[idx].createdAt,
          );
        }
      });
      _applyFilters();
      widget.onUnreadChanged?.call();
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    if (_adminId.isEmpty) return;
    setState(() => _markingAll = true);
    try {
      await _notificationService.markAllAsRead(_adminId);
      if (!mounted) return;
      setState(() {
        _allNotifications = _allNotifications.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            orderId: n.orderId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
      });
      _applyFilters();
      widget.onUnreadChanged?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai sudah dibaca'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${diff.inDays ~/ 7} minggu lalu';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data:\n$_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final hasUnread = _allNotifications.any((n) => !n.isRead);

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildFilterChips(),
        if (hasUnread) ...[
          const SizedBox(height: 8),
          _buildMarkAllButton(),
        ],
        const SizedBox(height: 12),
        Expanded(
          child: _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                          _filteredNotifications[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari judul atau isi notifikasi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE5E7EB)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filterOptions.map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
                _applyFilters();
              },
              selectedColor: const Color(0xff2563EB),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xff374151),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: selected
                    ? const Color(0xff2563EB)
                    : const Color(0xffE5E7EB),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarkAllButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _markingAll ? null : _markAllAsRead,
          icon: _markingAll
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.done_all, size: 18),
          label: const Text('Tandai Semua Dibaca'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xff2563EB),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? const Color(0xffE5E7EB)
              : const Color(0xff2563EB).withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _markAsRead(notification),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.grey.shade100
                    : const Color(0xff2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForType(notification.type),
                size: 22,
                color: notification.isRead
                    ? Colors.grey.shade400
                    : const Color(0xff2563EB),
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
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xff111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
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

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'return':
        return Icons.assignment_return_outlined;
      case 'product':
        return Icons.inventory_2_outlined;
      case 'withdrawal':
        return Icons.account_balance_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada notifikasi yang ditemukan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
