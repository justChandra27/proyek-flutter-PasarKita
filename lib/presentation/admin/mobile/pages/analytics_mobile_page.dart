import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/services/admin_analytics_service.dart';
import '../../../../core/services/product_service_appwrite.dart';

class _CategorySales {
  final String name;
  final int totalSold;

  _CategorySales({required this.name, required this.totalSold});
}

class AnalyticsMobilePage extends StatefulWidget {
  const AnalyticsMobilePage({super.key});

  @override
  State<AnalyticsMobilePage> createState() => _AnalyticsMobilePageState();
}

class _AnalyticsMobilePageState extends State<AnalyticsMobilePage> {
  final AdminAnalyticsService _analyticsService = AdminAnalyticsService();
  final Databases _db = AppwriteService.databases;
  final ProductServiceAppwrite _productService = ProductServiceAppwrite();

  AdminAnalytics? _data;
  List<_CategorySales> _topCategories = [];

  int _revenueToday = 0;
  int _revenueThisWeek = 0;
  int _revenueThisMonth = 0;

  List<_DayData> _revenue7Days = [];
  List<_DayData> _revenue30Days = [];
  List<_DayData> _orderTrend = [];
  List<_DayData> _userGrowth = [];

  TopSeller? _bestSeller;
  String _bestProduct = '';
  String _bestCategory = '';

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
        _analyticsService.getAnalytics(),
        _calcRevenueToday(),
        _calcRevenueThisWeek(),
        _calcRevenueThisMonth(),
        _fetchRevenueTrend7(),
        _fetchRevenueTrend30(),
        _fetchOrderTrend(),
        _fetchUserGrowth(),
        _fetchCategorySales(),
      ]);
      if (!mounted) return;
      final data = results[0] as AdminAnalytics;
      final topSellers = data.topSellers;
      final topProducts = data.topProducts;

      String bestProduct = '';
      if (topProducts.isNotEmpty) {
        bestProduct = topProducts.first.productName;
      }

      final cats = results[8] as List<_CategorySales>;
      String bestCategory = '';
      if (cats.isNotEmpty) {
        bestCategory = cats.first.name;
      }

      setState(() {
        _data = data;
        _revenueToday = results[1] as int;
        _revenueThisWeek = results[2] as int;
        _revenueThisMonth = results[3] as int;
        _revenue7Days = results[4] as List<_DayData>;
        _revenue30Days = results[5] as List<_DayData>;
        _orderTrend = results[6] as List<_DayData>;
        _userGrowth = results[7] as List<_DayData>;
        _topCategories = cats;
        _bestSeller = topSellers.isNotEmpty ? topSellers.first : null;
        _bestProduct = bestProduct;
        _bestCategory = bestCategory;
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

  Future<int> _calcRevenueToday() async {
    try {
      final start = DateTime.now();
      final startStr = DateTime(start.year, start.month, start.day)
          .toIso8601String();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.equal('status', 'completed'),
          Query.greaterThan('\$createdAt', startStr),
          Query.limit(5000),
        ],
      );
      int total = 0;
      for (final doc in result.documents) {
        total += (doc.data['totalAmount'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _calcRevenueThisWeek() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startStr = DateTime(weekStart.year, weekStart.month, weekStart.day)
          .toIso8601String();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.equal('status', 'completed'),
          Query.greaterThan('\$createdAt', startStr),
          Query.limit(5000),
        ],
      );
      int total = 0;
      for (final doc in result.documents) {
        total += (doc.data['totalAmount'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _calcRevenueThisMonth() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final startStr = monthStart.toIso8601String();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.equal('status', 'completed'),
          Query.greaterThan('\$createdAt', startStr),
          Query.limit(5000),
        ],
      );
      int total = 0;
      for (final doc in result.documents) {
        total += (doc.data['totalAmount'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<List<_DayData>> _fetchRevenueTrend7() async {
    return _buildRevenueTrend(7);
  }

  Future<List<_DayData>> _fetchRevenueTrend30() async {
    return _buildRevenueTrend(30);
  }

  Future<List<_DayData>> _buildRevenueTrend(int days) async {
    try {
      final start = DateTime.now().subtract(Duration(days: days));
      final startStr = start.toIso8601String();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.equal('status', 'completed'),
          Query.greaterThan('\$createdAt', startStr),
          Query.limit(5000),
        ],
      );
      final dayMap = <String, int>{};
      for (final doc in result.documents) {
        final raw = doc.$createdAt;
        if (raw.isEmpty) continue;
        try {
          final dt = DateTime.parse(raw);
          final key =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          dayMap[key] =
              (dayMap[key] ?? 0) + ((doc.data['totalAmount'] as num?)?.toInt() ?? 0);
        } catch (_) {}
      }
      final list = <_DayData>[];
      for (var i = days - 1; i >= 0; i--) {
        final d = DateTime.now().subtract(Duration(days: i));
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        list.add(_DayData(label: '${d.day}/${d.month}', value: dayMap[key] ?? 0));
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<_DayData>> _fetchOrderTrend() async {
    try {
      final start = DateTime.now().subtract(const Duration(days: 30));
      final startStr = start.toIso8601String();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.greaterThan('\$createdAt', startStr),
          Query.limit(5000),
        ],
      );
      final dayMap = <String, int>{};
      for (final doc in result.documents) {
        final raw = doc.$createdAt;
        if (raw.isEmpty) continue;
        try {
          final dt = DateTime.parse(raw);
          final key =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          dayMap[key] = (dayMap[key] ?? 0) + 1;
        } catch (_) {}
      }
      const days = 30;
      final list = <_DayData>[];
      for (var i = days - 1; i >= 0; i--) {
        final d = DateTime.now().subtract(Duration(days: i));
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        list.add(_DayData(label: '${d.day}/${d.month}', value: dayMap[key] ?? 0));
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<_DayData>> _fetchUserGrowth() async {
    try {
      final start = DateTime.now().subtract(const Duration(days: 30));
      final startStr = start.toIso8601String();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.greaterThan('\$createdAt', startStr),
          Query.limit(5000),
        ],
      );
      final dayMap = <String, int>{};
      for (final doc in result.documents) {
        final raw = doc.$createdAt;
        if (raw.isEmpty) continue;
        try {
          final dt = DateTime.parse(raw);
          final key =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          dayMap[key] = (dayMap[key] ?? 0) + 1;
        } catch (_) {}
      }
      const days = 30;
      final list = <_DayData>[];
      for (var i = days - 1; i >= 0; i--) {
        final d = DateTime.now().subtract(Duration(days: i));
        final key =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        list.add(_DayData(label: '${d.day}/${d.month}', value: dayMap[key] ?? 0));
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<_CategorySales>> _fetchCategorySales() async {
    try {
      final products = await _productService.getAllProducts();
      final catMap = <String, int>{};
      for (final p in products) {
        final cat = p.category.isNotEmpty ? p.category : 'Uncategorized';
        catMap[cat] = (catMap[cat] ?? 0) + (p.soldCount > 0 ? p.soldCount : 0);
      }
      final sorted = catMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted
          .take(5)
          .map((e) => _CategorySales(name: e.key, totalSold: e.value))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} JT';
    }
    final str = amount.toString();
    final parts = <String>[];
    int end = str.length;
    while (end > 0) {
      final start = (end - 3).clamp(0, end);
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return 'Rp ${parts.join('.')}';
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)} rb';
    }
    return n.toString();
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
                'Gagal memuat analytics:\n$_error',
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

    final data = _data!;
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
            _buildRevenueSection(),
            const SizedBox(height: 16),
            _buildOrderSection(data),
            const SizedBox(height: 16),
            _buildSellerSection(data),
            const SizedBox(height: 16),
            _buildProductSection(data),
            const SizedBox(height: 16),
            _buildCategorySection(),
            const SizedBox(height: 16),
            _buildChartsSection(),
            const SizedBox(height: 16),
            _buildInsightSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          const Text(
            'Belum ada data analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Data akan muncul setelah ada aktivitas marketplace.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRevenueSection() {
    return _buildSectionCard('Revenue', [
      Row(
        children: [
          Expanded(child: _miniStatCard('Total', _formatAmount(_data!.totalRevenue), Colors.deepPurple)),
          const SizedBox(width: 8),
          Expanded(child: _miniStatCard('Hari Ini', _formatAmount(_revenueToday), Colors.blue)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _miniStatCard('Minggu Ini', _formatAmount(_revenueThisWeek), Colors.teal)),
          const SizedBox(width: 8),
          Expanded(child: _miniStatCard('Bulan Ini', _formatAmount(_revenueThisMonth), Colors.green)),
        ],
      ),
    ]);
  }

  Widget _miniStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildOrderSection(AdminAnalytics data) {
    final counts = data.orderStatusCounts;
    return _buildSectionCard('Pesanan', [
      Row(
        children: [
          Expanded(child: _orderStatCard('Total', _formatNumber(data.totalOrders), Colors.grey)),
          const SizedBox(width: 8),
          Expanded(child: _orderStatCard('Pending', _formatNumber(counts['pending'] ?? 0), Colors.orange)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _orderStatCard('Diproses', _formatNumber(counts['processing'] ?? 0), Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _orderStatCard('Selesai', _formatNumber(counts['completed'] ?? 0), Colors.green)),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: _orderStatCard('Dibatalkan', _formatNumber(counts['cancelled'] ?? 0), Colors.red)),
          const SizedBox(width: 8),
          Expanded(child: _orderStatCard('AVG', _formatAmount(data.averageOrderValue), Colors.amber)),
        ],
      ),
    ]);
  }

  Widget _orderStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSellerSection(AdminAnalytics data) {
    if (data.topSellers.isEmpty) {
      return _buildSectionCard('Top Seller', [
        const Text('Belum ada data seller.',
            style: TextStyle(color: Colors.grey)),
      ]);
    }
    return _buildSectionCard('Top Seller', [
      ...data.topSellers.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final s = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text('$i.',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6B7280))),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('${s.completedOrdersCount} pesanan',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Text(_formatAmount(s.totalRevenue),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff111827))),
            ],
          ),
        );
      }),
    ]);
  }

  Widget _buildProductSection(AdminAnalytics data) {
    if (data.topProducts.isEmpty) {
      return _buildSectionCard('Top Produk', [
        const Text('Belum ada data produk.',
            style: TextStyle(color: Colors.grey)),
      ]);
    }
    return _buildSectionCard('Top Produk', [
      ...data.topProducts.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final p = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text('$i.',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6B7280))),
              ),
              Expanded(
                child: Text(p.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
              Text('${p.totalSold} terjual',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        );
      }),
    ]);
  }

  Widget _buildCategorySection() {
    if (_topCategories.isEmpty) {
      return _buildSectionCard('Kategori Terlaris', [
        const Text('Belum ada data kategori.',
            style: TextStyle(color: Colors.grey)),
      ]);
    }
    return _buildSectionCard('Kategori Terlaris', [
      ..._topCategories.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final c = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text('$i.',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6B7280))),
              ),
              Expanded(
                child: Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Text('${c.totalSold} terjual',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        );
      }),
    ]);
  }

  Widget _buildChartsSection() {
    return _buildSectionCard('Grafik', [
      const Text('Revenue 7 Hari',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 180,
        child: _buildBarChart(_revenue7Days),
      ),
      const Divider(height: 32),
      const Text('Revenue 30 Hari',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 180,
        child: _buildBarChart(_revenue30Days),
      ),
      const Divider(height: 32),
      const Text('Tren Pesanan (30 Hari)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 180,
        child: _buildBarChart(_orderTrend),
      ),
      const Divider(height: 32),
      const Text('Pertumbuhan User (30 Hari)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 180,
        child: _buildBarChart(_userGrowth),
      ),
    ]);
  }

  Widget _buildBarChart(List<_DayData> data) {
    if (data.isEmpty) {
      return Center(
        child: Text('Belum ada data',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }
    final maxVal = data.fold<int>(0, (m, d) => d.value > m ? d.value : m);
    final effectiveMax = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: effectiveMax.toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = data[group.x.toInt()];
              return BarTooltipItem(
                '${item.label}\n${_formatAmount(item.value)}',
                const TextStyle(color: Colors.white, fontSize: 11),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                final show = data.length > 15
                    ? idx % 5 == 0
                    : data.length > 7
                        ? idx % 3 == 0
                        : true;
                if (!show) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(data[idx].label,
                      style: TextStyle(
                          fontSize: 9, color: Colors.grey.shade600)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value >= 1000000
                      ? '${(value / 1000000).toStringAsFixed(0)}JT'
                      : value >= 1000
                          ? '${(value / 1000).toStringAsFixed(0)}rb'
                          : value.toInt().toString(),
                  style:
                      TextStyle(fontSize: 9, color: Colors.grey.shade600),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: effectiveMax > 0 ? effectiveMax / 4 : 25,
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: Colors.blue.shade400,
                width: data.length > 15 ? 4 : 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightSection() {
    return _buildSectionCard('Insight Bulan Ini', [
      if (_bestSeller != null) ...[
        _insightRow(Icons.emoji_events, 'Seller Terbaik', _bestSeller!.name),
        const SizedBox(height: 8),
      ],
      if (_bestProduct.isNotEmpty)
        _insightRow(Icons.inventory_2, 'Produk Terbaik', _bestProduct),
      if (_bestProduct.isNotEmpty) const SizedBox(height: 8),
      if (_bestCategory.isNotEmpty)
        _insightRow(Icons.category, 'Kategori Terbaik', _bestCategory),
      if (_bestSeller == null && _bestProduct.isEmpty && _bestCategory.isEmpty)
        const Text('Belum ada insight.',
            style: TextStyle(color: Colors.grey)),
    ]);
  }

  Widget _insightRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.amber.shade600),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _DayData {
  final String label;
  final int value;

  _DayData({required this.label, required this.value});
}
