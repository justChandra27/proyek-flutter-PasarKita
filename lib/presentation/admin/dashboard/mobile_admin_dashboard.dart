import 'package:flutter/material.dart';

import '../../../core/services/admin_analytics_service.dart';

class MobileAdminDashboard extends StatefulWidget {
  const MobileAdminDashboard({super.key});

  @override
  State<MobileAdminDashboard> createState() =>
      _MobileAdminDashboardState();
}

class _MobileAdminDashboardState
    extends State<MobileAdminDashboard> {
  final AdminAnalyticsService _analytics = AdminAnalyticsService();
  late Future<AdminAnalytics> _analyticsFuture;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _analytics.getAnalytics();
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: const Color(0xffF7F8FC),
        body: FutureBuilder<AdminAnalytics>(
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
        bottomNavigationBar:
            BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor:
              const Color(0xff2962FF),
          unselectedItemColor:
              Colors.grey,
          type:
              BottomNavigationBarType.fixed,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: "Produk",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "User",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Laporan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profil",
            ),
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

  Widget _buildContent(AdminAnalytics data) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PasarKita",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Panel Admin",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: Colors.black,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration:
                            const BoxDecoration(
                          color: Colors.red,
                          shape:
                              BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor:
                      Color(0xff2962FF),
                  child: Text(
                    "A",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BANNER
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(24),
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xff2962FF),
                    Color(0xff5C8DFF),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, Admin 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Kelola pengguna, produk,\npesanan, transaksi dan laporan sistem.",
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Ringkasan Sistem",
              style: TextStyle(
                color: Color(0xff111827),
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                SummaryCard(
                  title: "Total Customer",
                  value: _formatNumber(data.totalCustomers),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                SummaryCard(
                  title: "Total Seller",
                  value: _formatNumber(data.totalSellers),
                  icon: Icons.store,
                  color: Colors.teal,
                ),
                SummaryCard(
                  title: "Total Produk",
                  value: _formatNumber(data.totalProducts),
                  icon: Icons.inventory_2,
                  color: Colors.orange,
                ),
                SummaryCard(
                  title: "Total Order",
                  value: _formatNumber(data.totalOrders),
                  icon: Icons.shopping_bag,
                  color: Colors.green,
                ),
                SummaryCard(
                  title: "Order Completed",
                  value: _formatNumber(data.completedOrders),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                SummaryCard(
                  title: "Total Revenue",
                  value: _formatPrice(data.totalRevenue),
                  icon: Icons.account_balance_wallet,
                  color: Colors.deepPurple,
                ),
                SummaryCard(
                  title: "Platform Revenue",
                  value: _formatPrice(data.totalPlatformRevenue),
                  icon: Icons.account_balance,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // STATUS ORDER
            if (data.orderStatusCounts.isNotEmpty) ...[
              const Text(
                "Status Order",
                style: TextStyle(
                  color: Color(0xff111827),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.orderStatusCounts.entries.map((e) {
                  return _statusChip(e.key, e.value);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // TOP PRODUK
            if (data.topProducts.isNotEmpty) ...[
              const Text(
                "Produk Terlaris",
                style: TextStyle(
                  color: Color(0xff111827),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...data.topProducts.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(p.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text(
                          '${p.totalSold} terjual',
                          style: const TextStyle(
                            color: Color(0xff2962FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // TOP SELLER
            if (data.topSellers.isNotEmpty) ...[
              const Text(
                "Top Seller",
                style: TextStyle(
                  color: Color(0xff111827),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...data.topSellers.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
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
                            color: Color(0xff2962FF),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(_statusLabel(status), style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _statusColor(status),
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
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: color, size: 30),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff6B7280),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff111827),
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
