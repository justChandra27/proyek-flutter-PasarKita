import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../data/models/order_model.dart';

import 'order_detail_mobile_page.dart';

class OrdersMobilePage extends StatefulWidget {
  const OrdersMobilePage({super.key});

  @override
  State<OrdersMobilePage> createState() => _OrdersMobilePageState();
}

class _OrdersMobilePageState extends State<OrdersMobilePage> {
  final Databases _db = AppwriteService.databases;
  final TextEditingController _searchController = TextEditingController();

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'Semua';

  static const _filterOptions = [
    'Semua',
    'Unpaid',
    'Verification',
    'Paid',
    'Rejected',
  ];

  static const _paymentStatusMap = {
    'Unpaid': 'unpaid',
    'Verification': 'verification',
    'Paid': 'paid',
    'Rejected': 'rejected',
  };

  @override
  void initState() {
    super.initState();
    _loadOrders();
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

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );
      final orders = result.documents.map((doc) {
        return OrderModel.fromMap(doc.$id, doc.data);
      }).toList();
      if (!mounted) return;
      setState(() {
        _allOrders = orders;
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
    final paymentFilter = _selectedFilter;

    setState(() {
      _filteredOrders = _allOrders.where((o) {
        if (paymentFilter != 'Semua') {
          final targetStatus = _paymentStatusMap[paymentFilter];
          if (o.paymentStatus.toLowerCase() != targetStatus) return false;
        }
        if (query.isNotEmpty) {
          final matchesCode = o.orderCode.toLowerCase().contains(query);
          final matchesName = o.customerName.toLowerCase().contains(query);
          if (!matchesCode && !matchesName) return false;
        }
        return true;
      }).toList();
    });
  }

  Color _paymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verification':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'unpaid':
      default:
        return Colors.grey;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'verification':
        return 'Verification';
      case 'paid':
        return 'Paid';
      case 'rejected':
        return 'Rejected';
      case 'unpaid':
        return 'Unpaid';
      default:
        return status;
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

  String _formatDate(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return createdAt;
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
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildFilterChips(),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredOrders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(_filteredOrders[index]);
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
          hintText: 'Cari order code atau customer...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
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

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailMobilePage(orderId: order.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xff111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _paymentStatusColor(order.paymentStatus)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _paymentStatusLabel(order.paymentStatus),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _paymentStatusColor(order.paymentStatus),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 16, color: Color(0xff6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.receipt_outlined,
                    size: 16, color: Color(0xff6B7280)),
                const SizedBox(width: 6),
                Text(
                  _formatPrice(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff111827),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
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
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada pesanan yang ditemukan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
