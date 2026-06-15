import 'package:flutter/material.dart';

import '../../../core/services/admin_analytics_service.dart';

class FormLaporanWeb extends StatefulWidget {
  const FormLaporanWeb({super.key});

  @override
  State<FormLaporanWeb> createState() => _FormLaporanWebState();
}

class _FormLaporanWebState extends State<FormLaporanWeb> {
  final _analyticsService = AdminAnalyticsService();
  AdminAnalytics? _analytics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Laporan Analytics",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 260,
                          child: TextField(
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
                        ),
                        const SizedBox(width: 20),
                        const Badge(
                          child: Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 10,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/150",
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin Utama",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Administrator",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // STAT CARD
                    _buildStatCards(),
                    const SizedBox(height: 24),
                    _buildTopProducts(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCards() {
    final analytics = _analytics;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.payments_outlined,
            "Total Penjualan",
            analytics != null
                ? _formatCurrency(analytics.totalRevenue)
                : "Rp 0",
            analytics != null
                ? '${_formatNumber(analytics.completedOrders)} pesanan selesai'
                : "Belum ada data",
            Colors.green,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            Icons.shopping_cart_checkout,
            "Pesanan Selesai",
            analytics != null
                ? _formatNumber(analytics.completedOrders)
                : "0",
            'Dari ${analytics != null ? _formatNumber(analytics.totalOrders) : "0"} total pesanan',
            Colors.green,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            Icons.person_add_alt_1,
            "Pengguna Baru",
            analytics != null
                ? _formatNumber(analytics.totalCustomers)
                : "0",
            '${analytics != null ? _formatNumber(analytics.totalSellers) : "0"} penjual',
            Colors.black54,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            Icons.show_chart,
            "Rata Transaksi",
            analytics != null && analytics.completedOrders > 0
                ? _formatCurrency(analytics.averageOrderValue)
                : "Rp 0",
            analytics != null
                ? '${_formatNumber(analytics.totalOrders)} total transaksi'
                : "Belum ada data",
            Colors.grey,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProducts() {
    final topProducts = _analytics?.topProducts ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Produk Terlaris",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "Belum ada data produk terjual",
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            ...topProducts.map((p) => _productItem(p.productName, p.totalSold)),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff2563EB),
            ),
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text("Lihat Semua Produk"),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color subtitleColor,
    Color iconColor,
  ) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: .15),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productItem(String name, int sold) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_2_outlined, color: Colors.black45),
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$sold terjual'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xff2563EB).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
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
