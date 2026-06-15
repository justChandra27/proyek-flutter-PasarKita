import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/balance_service_appwrite.dart';
import '../../../core/services/seller_analytics_service.dart';
import '../../../data/models/seller_balance_model.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../withdrawal/withdrawal_page.dart';

class DashboardSellerWeb extends StatefulWidget {
  const DashboardSellerWeb({super.key});

  @override
  State<DashboardSellerWeb> createState() => _DashboardSellerWebState();
}

class _DashboardSellerWebState extends State<DashboardSellerWeb> {
  final SellerAnalyticsService _analytics = SellerAnalyticsService();
  final BalanceServiceAppwrite _balanceService = BalanceServiceAppwrite();
  late Future<SellerAnalytics> _analyticsFuture;
  SellerBalanceModel? _balance;
  String _sellerName = 'Seller';
  String _initial = 'S';

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _load();
  }

  Future<SellerAnalytics> _load() async {
    final auth = AuthServiceAppwrite();
    final account = await auth.getCurrentUser();
    final databases = AppwriteService.databases;
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.usersCollectionId,
      queries: [Query.equal('uid', account.$id)],
    );
    final name = account.name;
    if (result.documents.isNotEmpty) {
      final data = result.documents.first.data;
      final displayName = (data['storeName'] as String?)?.isNotEmpty == true
          ? data['storeName'] as String
          : name;
      if (mounted) {
        setState(() {
          _sellerName = displayName;
          _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _sellerName = name;
          _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
        });
      }
    }
    final analytics = await _analytics.getAnalytics(account.$id);
    final bal = await _balanceService.getBalance(account.$id);
    if (mounted) setState(() => _balance = bal);
    return analytics;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SellerAnalytics data) {
    return Column(
      children: [
        _header(),
        const SizedBox(height: 30),
        const Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ringkasan Merchant",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Selamat datang kembali, mari lihat perkembangan toko Anda hari ini.",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // STAT CARDS
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Total Pendapatan",
                _formatPrice(data.totalRevenue),
                Icons.payments_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Total Pesanan",
                '${data.totalOrders}',
                Icons.shopping_cart_outlined,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Pesanan Selesai",
                '${data.completedOrders}',
                Icons.check_circle_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Total Produk",
                '${data.totalProducts}',
                Icons.inventory_2_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Produk Aktif",
                '${data.activeProducts}',
                Icons.check_circle_outline,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                "Menunggu Review",
                '${data.pendingReviewProducts}',
                Icons.hourglass_empty,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.account_balance_wallet, color: Colors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo Tersedia', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(_balance?.balance ?? 0),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WithdrawalPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Tarik'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // STATUS PESANAN
        if (data.orderStatusCounts.isNotEmpty) ...[
          Row(
            children: data.orderStatusCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _statusChip(
                  label: _statusLabel(entry.key),
                  count: entry.value,
                  color: _statusColor(entry.key),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // PRODUK TERLARIS + REVIEWS
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _topProductsSection(data.topProducts),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _reviewsCard(data.totalReviews, data.averageRating),
                    const SizedBox(height: 16),
                    Expanded(child: _quickMenu()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari pesanan atau produk...",
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
        ),
        const SizedBox(width: 20),
        Text(
          _sellerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xff2563EB),
          child: Text(
            _initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: 
      Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    CircleAvatar(
      child: Icon(icon),
    ),

    SizedBox(height: 12),

    Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),

    SizedBox(height: 8),

    FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
)
    );
  }

  Widget _statusChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _topProductsSection(List<ProductSales> topProducts) {
    if (topProducts.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'Belum ada produk terjual',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Produk Terlaris",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...topProducts.map((p) => _productRow(p.productName, p.totalSold)),
        ],
      ),
    );
  }

  Widget _reviewsCard(int totalReviews, double averageRating) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text(
                'Ulasan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalReviews',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Total Ulasan',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productRow(String name, int sold) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
      ),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        '$sold terjual',
        style: const TextStyle(
          color: Color(0xff2563EB),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _quickMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _QuickItem("Tambah Produk", Icons.add_box),
          _QuickItem("Laporan", Icons.bar_chart),
          _QuickItem("Promosi", Icons.campaign),
          _QuickItem("Pengaturan", Icons.settings),
        ],
      ),
    );
  }
}

class _QuickItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _QuickItem(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xff2563EB)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
