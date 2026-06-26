import 'package:flutter/material.dart';

import '../../../core/services/admin_analytics_service.dart';

class DashboardAdminWeb extends StatefulWidget {
  const DashboardAdminWeb({super.key});

  @override
  State<DashboardAdminWeb> createState() => _DashboardAdminWebState();
}

class _DashboardAdminWebState extends State<DashboardAdminWeb> {
  final AdminAnalyticsService _analytics = AdminAnalyticsService();
  late Future<AdminAnalytics> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _analytics.getAnalytics();
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)}M';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<AdminAnalytics>(
          future: _analyticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Gagal memuat data:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final isEmpty = data.totalProducts == 0 && data.totalOrders == 0;

            if (isEmpty) {
              return _buildEmptyState();
            }

            return _buildContent(data);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminAnalytics data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatCards(data),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTopSellers(data)),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildTopProducts(data)),
              const SizedBox(width: 20),
              Expanded(flex: 1, child: _buildStatusSection(data)),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Dashboard",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          "Halo, Admin 👋",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Cari transaksi...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
        ),
      ],
    );
  }

  Widget _buildStatCards(AdminAnalytics data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Total Customer",
                _formatNumber(data.totalCustomers),
                Icons.people_outline,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Total Seller",
                _formatNumber(data.totalSellers),
                Icons.store_outlined,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Total Produk",
                _formatNumber(data.totalProducts),
                Icons.inventory_2_outlined,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Total Order",
                _formatNumber(data.totalOrders),
                Icons.shopping_bag_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Order Completed",
                _formatNumber(data.completedOrders),
                Icons.check_circle_outlined,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Total Revenue",
                _formatPrice(data.totalRevenue),
                Icons.payments_outlined,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Platform Revenue",
                _formatPrice(data.totalPlatformRevenue),
                Icons.account_balance,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Pending Products",
                _formatNumber(data.pendingProducts),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Pending Withdrawals",
                _formatPrice(data.pendingWithdrawalAmount),
                Icons.money_off,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
              child: Text(
                'Belum ada seller',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...data.topSellers.map(
              (s) => Padding(
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
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${s.completedOrdersCount} pesanan selesai',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
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
              ),
            ),
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
              child: Text(
                'Belum ada produk terjual',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...data.topProducts.map(
              (p) => Padding(
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
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
              ),
            ),
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
          ...data.orderStatusCounts.entries.map(
            (e) => Padding(
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
            ),
          ),
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

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(Icons.person_add_alt, "Verifikasi User"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionButton(Icons.add_box_outlined, "Tambah Produk"),
          ),
          const SizedBox(width: 16),
          Expanded(child: _actionButton(Icons.campaign_outlined, "Buat Promo")),
          const SizedBox(width: 16),
          Expanded(child: _actionButton(Icons.download, "Export Laporan")),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String title) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xffF5F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}
