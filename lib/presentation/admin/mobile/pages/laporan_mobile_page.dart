import 'package:flutter/material.dart';

import '../../../../core/services/admin_analytics_service.dart';
import 'products_mobile_page.dart';

class LaporanMobilePage extends StatefulWidget {
  const LaporanMobilePage({super.key});

  @override
  State<LaporanMobilePage> createState() => _LaporanMobilePageState();
}

class _LaporanMobilePageState extends State<LaporanMobilePage> {
  final _analyticsService = AdminAnalyticsService();
  AdminAnalytics? _analytics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _analyticsService.getAnalytics();
      if (!mounted) return;
      setState(() {
        _analytics = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Cari laporan...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildStatCard(
              Icons.payments_outlined,
              'Total Penjualan',
              _analytics != null ? _formatCurrency(_analytics!.totalRevenue) : 'Rp 0',
              _analytics != null ? '${_formatNumber(_analytics!.completedOrders)} pesanan selesai' : 'Belum ada data',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              Icons.shopping_cart_checkout,
              'Pesanan Selesai',
              _analytics != null ? _formatNumber(_analytics!.completedOrders) : '0',
              _analytics != null ? 'Dari ${_formatNumber(_analytics!.totalOrders)} total pesanan' : 'Belum ada data',
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              Icons.person_add_alt_1,
              'Pengguna Baru',
              _analytics != null ? _formatNumber(_analytics!.totalCustomers) : '0',
              _analytics != null ? '${_formatNumber(_analytics!.totalSellers)} penjual' : 'Belum ada data',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              Icons.show_chart,
              'Rata Transaksi',
              _analytics != null && _analytics!.completedOrders > 0
                  ? _formatCurrency(_analytics!.averageOrderValue)
                  : 'Rp 0',
              _analytics != null ? '${_formatNumber(_analytics!.totalOrders)} total transaksi' : 'Belum ada data',
              Colors.teal,
            ),
            const SizedBox(height: 24),
            _buildTopProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, String subtitle, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xff6B7280))),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff111827)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = _analytics?.topProducts ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produk Terlaris',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff111827)),
          ),
          const SizedBox(height: 12),
          if (topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Belum ada data produk terjual', style: TextStyle(color: Color(0xff6B7280))),
              ),
            )
          else
            ...topProducts.map((p) => _productItem(p.productName, p.totalSold)),
          const SizedBox(height: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff2563EB),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsMobilePage()),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text("Lihat Semua Produk"),
          ),
        ],
      ),
    );
  }

  Widget _productItem(String name, int sold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Color(0xff6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff111827))),
                const SizedBox(height: 2),
                Text('$sold terjual', style: const TextStyle(fontSize: 13, color: Color(0xff6B7280))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xff2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatNumber(sold),
              style: const TextStyle(
                color: Color(0xff2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return 'Rp ${_formatNumber(amount)}';
  }

  String _formatNumber(int n) {
    if (n == 0) return '0';
    final str = n.toString();
    final parts = <String>[];
    int end = str.length;
    while (end > 0) {
      final start = (end - 3).clamp(0, end);
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return parts.join('.');
  }
}
