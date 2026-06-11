import 'package:flutter/material.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/seller_analytics_service.dart';
import '../profile/profile_seller_mobile.dart';

class MobileSellerDashboard extends StatefulWidget {
  const MobileSellerDashboard({super.key});

  @override
  State<MobileSellerDashboard> createState() => _MobileSellerDashboardState();
}

class _MobileSellerDashboardState extends State<MobileSellerDashboard> {
  final SellerAnalyticsService _analytics = SellerAnalyticsService();
  late Future<SellerAnalytics> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _load();
  }

  Future<SellerAnalytics> _load() async {
    final account = await AuthServiceAppwrite().getCurrentUser();
    return _analytics.getAnalytics(account.$id);
  }

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Perlu Diproses';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: FutureBuilder<SellerAnalytics>(
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
            final isEmpty =
                data.totalProducts == 0 && data.totalOrders == 0;

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Icon(Icons.store_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          const Text(
            'Belum ada data penjualan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk pertama Anda untuk mulai berjualan.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SellerAnalytics data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, Andi 👋",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Selamat datang kembali",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SellerEditProfileMobile(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TOTAL PENDAPATAN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xff2563EB), Color(0xff4F46E5)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "TOTAL PENDAPATAN",
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _formatPrice(data.totalRevenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.completedOrders} pesanan selesai',
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // STAT RINGKASAN
          Row(
            children: [
              Expanded(
                child: _miniCard(
                  title: "Total Produk",
                  value: '${data.totalProducts}',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xffDBEAFE),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniCard(
                  title: "Total Pesanan",
                  value: '${data.totalOrders}',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xffFEF3C7),
                ),
              ),
              Expanded(
                child: _miniCard(
                  title: "Pesanan Selesai",
                  value: '${data.completedOrders}',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xffDCFCE7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // STATUS PESANAN
          if (data.orderStatusCounts.isNotEmpty) ...[
            const Text(
              "Status Pesanan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.orderStatusCounts.entries.map((entry) {
                return _statusChip(
                  label: _statusLabel(entry.key),
                  count: entry.value,
                  color: _statusColor(entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
          ],

          // PRODUK TERLARIS
          if (data.topProducts.isNotEmpty) ...[
            const Text(
              "Produk Terlaris",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...data.topProducts
                .map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _topProductCard(p.productName, p.totalSold),
                    )),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _miniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _topProductCard(String name, int sold) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$sold terjual',
            style: const TextStyle(
              color: Color(0xff2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
