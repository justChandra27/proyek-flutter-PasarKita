import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/services/admin_analytics_service.dart';
import '../../../../core/services/notification_service_appwrite.dart';
import '../../../../core/services/auth_service_appwrite.dart';

import 'analytics_mobile_page.dart';

class DashboardMobilePage extends StatefulWidget {
  const DashboardMobilePage({super.key});

  @override
  State<DashboardMobilePage> createState() => _DashboardMobilePageState();
}

class _DashboardMobilePageState extends State<DashboardMobilePage> {
  final AdminAnalyticsService _analytics = AdminAnalyticsService();
  final NotificationServiceAppwrite _notificationService =
      NotificationServiceAppwrite();
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  final Databases _db = AppwriteService.databases;

  AdminAnalytics? _analyticsData;
  List<Map<String, dynamic>>? _recentOrders;
  int _pendingReturnCount = 0;
  int _unreadNotificationCount = 0;
  int _activeUserCount = 0;
  int _activeSellerCount = 0;
  int _pendingWithdrawalCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _analytics.getAnalytics(),
        _fetchRecentOrders(),
        _fetchPendingReturnCount(),
        _fetchUnreadNotificationCount(),
        _fetchActiveUserCount(),
        _fetchActiveSellerCount(),
        _fetchPendingWithdrawalCount(),
      ]);
      if (!mounted) return;
      setState(() {
        _analyticsData = results[0] as AdminAnalytics;
        _recentOrders = results[1] as List<Map<String, dynamic>>;
        _pendingReturnCount = results[2] as int;
        _unreadNotificationCount = results[3] as int;
        _activeUserCount = results[4] as int;
        _activeSellerCount = results[5] as int;
        _pendingWithdrawalCount = results[6] as int;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecentOrders() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: [
        Query.orderDesc('\$createdAt'),
        Query.limit(10),
      ],
    );
    return result.documents.map((d) {
      final data = Map<String, dynamic>.from(d.data);
      data['\$id'] = d.$id;
      data['\$createdAt'] = d.$createdAt;
      return data;
    }).toList();
  }

  Future<int> _fetchPendingReturnCount() async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.returnsCollectionId,
        queries: [
          Query.equal('status', 'requested'),
          Query.limit(1),
        ],
      );
      return result.total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchUnreadNotificationCount() async {
    try {
      final adminData = await _authService.getCurrentUserData();
      if (adminData == null) return 0;
      final uid = adminData['uid'] as String? ?? '';
      if (uid.isEmpty) return 0;
      return await _notificationService.getUnreadCount(uid);
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchActiveUserCount() async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('status', 'active'),
          Query.limit(1),
        ],
      );
      return result.total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchActiveSellerCount() async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('role', 'seller'),
          Query.equal('status', 'active'),
          Query.limit(1),
        ],
      );
      return result.total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchPendingWithdrawalCount() async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.withdrawalsCollectionId,
        queries: [
          Query.equal('status', 'pending'),
          Query.limit(1),
        ],
      );
      return result.total;
    } catch (_) {
      return 0;
    }
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)} JT';
    }
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)} rb';
    }
    return n.toString();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return const Color(0xff2563EB);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
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
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _analyticsData!;
    final isEmpty = data.totalProducts == 0 && data.totalOrders == 0;

    if (isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryGrid(data),
            const SizedBox(height: 16),
            _buildAnalyticsShortcut(),
            const SizedBox(height: 24),
            if (_recentOrders != null && _recentOrders!.isNotEmpty)
              _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildTopSellers(data),
            const SizedBox(height: 24),
            _buildTopProducts(data),
            const SizedBox(height: 24),
            _buildStatusSection(data),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsShortcut() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AnalyticsMobilePage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff2563EB), Color(0xff7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Marketplace',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lihat grafik revenue, tren pesanan, dan insight',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'Belum ada aktivitas marketplace',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Data akan muncul setelah ada pengguna, produk, dan transaksi.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(AdminAnalytics data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Sistem',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff111827),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _StatCard(
              icon: Icons.people,
              title: 'Total Customer',
              value: _formatNumber(data.totalCustomers),
              color: Colors.blue,
            ),
            _StatCard(
              icon: Icons.store,
              title: 'Total Seller',
              value: _formatNumber(data.totalSellers),
              color: Colors.teal,
            ),
            _StatCard(
              icon: Icons.person,
              title: 'User Aktif',
              value: _formatNumber(_activeUserCount),
              color: Colors.lightGreen,
            ),
            _StatCard(
              icon: Icons.storefront,
              title: 'Seller Aktif',
              value: _formatNumber(_activeSellerCount),
              color: Colors.green,
            ),
            _StatCard(
              icon: Icons.inventory_2,
              title: 'Total Produk',
              value: _formatNumber(data.totalProducts),
              color: Colors.orange,
            ),
            _StatCard(
              icon: Icons.pending_actions,
              title: 'Produk Menunggu',
              value: _formatNumber(data.pendingProducts),
              color: Colors.deepOrange,
            ),
            _StatCard(
              icon: Icons.shopping_bag,
              title: 'Total Pesanan',
              value: _formatNumber(data.totalOrders),
              color: Colors.green,
            ),
            _StatCard(
              icon: Icons.check_circle,
              title: 'Pesanan Selesai',
              value: _formatNumber(data.completedOrders),
              color: const Color(0xff059669),
            ),
            _StatCard(
              icon: Icons.account_balance_wallet,
              title: 'Total Revenue',
              value: _formatPrice(data.totalRevenue),
              color: Colors.deepPurple,
            ),
            _StatCard(
              icon: Icons.account_balance,
              title: 'Platform Revenue',
              value: _formatPrice(data.totalPlatformRevenue),
              color: Colors.amber,
            ),
            _StatCard(
              icon: Icons.money_off,
              title: 'Pending Withdrawal',
              value: _formatPrice(data.pendingWithdrawalAmount),
              color: Colors.red,
            ),
            _StatCard(
              icon: Icons.assignment_return,
              title: 'Retur Menunggu',
              value: _formatNumber(_pendingReturnCount),
              color: Colors.orange,
            ),
            _StatCard(
              icon: Icons.account_balance_wallet,
              title: 'Withdrawal Pending',
              value: _formatNumber(_pendingWithdrawalCount),
              color: Colors.amber,
            ),
            _StatCard(
              icon: Icons.notifications_outlined,
              title: 'Notifikasi Belum Dibaca',
              value: _formatNumber(_unreadNotificationCount),
              color: const Color(0xff2563EB),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff111827),
          ),
        ),
        const SizedBox(height: 12),
        ..._recentOrders!.map((order) {
          final status = (order['status'] as String?) ?? 'pending';
          final total = (order['totalAmount'] as num?)?.toInt() ?? 0;
          final createdAt = order['\$createdAt'] as String? ?? '';
          final orderId = (order['\$id'] as String?) ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_outlined,
                    color: _statusColor(status),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeAgo(createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatPrice(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff111827),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopSellers(AdminAnalytics data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Seller",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (data.topSellers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Belum ada seller',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ...data.topSellers.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('${s.completedOrdersCount} pesanan selesai',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        _formatPrice(s.totalRevenue),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2563EB),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildTopProducts(AdminAnalytics data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Produk Terlaris",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (data.topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Belum ada produk terjual',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ...data.topProducts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: Colors.grey, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(p.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        '${p.totalSold} terjual',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2563EB),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildStatusSection(AdminAnalytics data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status Order",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...data.orderStatusCounts.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _statusColor(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusLabel(e.key),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${e.value}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rata-rata Pesanan",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(data.averageOrderValue),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Aksi Cepat",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _actionButton(Icons.person_add_alt, "Verifikasi User")),
              const SizedBox(width: 12),
              Expanded(
                  child: _actionButton(Icons.add_box_outlined, "Tambah Produk")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _actionButton(Icons.campaign_outlined, "Buat Promo")),
              const SizedBox(width: 12),
              Expanded(
                  child: _actionButton(Icons.download, "Export Laporan")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fitur tersedia di menu $title')),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xffF5F7FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff6B7280),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff111827),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
