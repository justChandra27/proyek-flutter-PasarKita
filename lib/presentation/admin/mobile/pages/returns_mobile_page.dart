import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../data/models/return_model.dart';

import 'return_detail_mobile_page.dart';

class _ReturnDisplayItem {
  final ReturnModel returnModel;
  final String customerName;
  final String productName;

  _ReturnDisplayItem({
    required this.returnModel,
    required this.customerName,
    required this.productName,
  });
}

class ReturnsMobilePage extends StatefulWidget {
  const ReturnsMobilePage({super.key});

  @override
  State<ReturnsMobilePage> createState() => _ReturnsMobilePageState();
}

class _ReturnsMobilePageState extends State<ReturnsMobilePage> {
  final Databases _db = AppwriteService.databases;
  final TextEditingController _searchController = TextEditingController();

  List<_ReturnDisplayItem> _allItems = [];
  List<_ReturnDisplayItem> _filteredItems = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'Semua';

  static const _filterOptions = [
    'Semua',
    'Requested',
    'Approved',
    'Rejected',
    'Received',
    'Refunded',
  ];

  @override
  void initState() {
    super.initState();
    _loadReturns();
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

  Future<void> _loadReturns() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final returnsResult = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.returnsCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );
      final returns = returnsResult.documents.map((doc) {
        return ReturnModel.fromMap(doc.$id, doc.data);
      }).toList();

      final orderIds = returns
          .map((r) => r.orderId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final customerNames = await _batchFetchCustomerNames(orderIds);

      final itemIds = returns
          .map((r) => r.orderItemId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final productNames = await _batchFetchProductNames(itemIds);

      final items = returns.map((r) {
        return _ReturnDisplayItem(
          returnModel: r,
          customerName: customerNames[r.orderId] ?? 'Unknown',
          productName: productNames[r.orderItemId] ?? 'Unknown Product',
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _allItems = items;
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

  Future<Map<String, String>> _batchFetchCustomerNames(
      List<String> orderIds) async {
    final map = <String, String>{};
    for (var i = 0; i < orderIds.length; i += 100) {
      final chunk = orderIds.sublist(
          i, (i + 100).clamp(0, orderIds.length));
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('\$id', chunk)],
      );
      for (final doc in result.documents) {
        map[doc.$id] = doc.data['customerName'] as String? ?? 'Unknown';
      }
    }
    return map;
  }

  Future<Map<String, String>> _batchFetchProductNames(
      List<String> itemIds) async {
    final map = <String, String>{};
    for (var i = 0; i < itemIds.length; i += 100) {
      final chunk =
          itemIds.sublist(i, (i + 100).clamp(0, itemIds.length));
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.orderItemsCollectionId,
        queries: [Query.equal('\$id', chunk)],
      );
      for (final doc in result.documents) {
        map[doc.$id] =
            doc.data['productName'] as String? ?? 'Unknown Product';
      }
    }
    return map;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredItems = _allItems.where((item) {
        if (_selectedFilter != 'Semua') {
          if (item.returnModel.status.toLowerCase() !=
              _selectedFilter.toLowerCase()) {
            return false;
          }
        }
        if (query.isNotEmpty) {
          final returnId = item.returnModel.id.toLowerCase();
          final orderCode = item.returnModel.orderCode.toLowerCase();
          final customer = item.customerName.toLowerCase();
          final product = item.productName.toLowerCase();
          if (!returnId.contains(query) &&
              !orderCode.contains(query) &&
              !customer.contains(query) &&
              !product.contains(query)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'received':
        return Colors.purple;
      case 'refunded':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'Requested';
      case 'approved':
        return 'Approved';
      case 'received':
        return 'Received';
      case 'refunded':
        return 'Refunded';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _shortId(String id) {
    return id.length > 8 ? 'RET-${id.substring(0, 8).toUpperCase()}' : 'RET-$id';
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
                onPressed: _loadReturns,
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
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReturns,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildReturnCard(_filteredItems[index]);
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
          hintText: 'Cari return ID, order, customer, produk...',
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
              selectedColor: _statusColor(filter == 'Semua' ? '' : filter),
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
                    ? _statusColor(filter == 'Semua' ? '' : filter)
                    : const Color(0xffE5E7EB),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReturnCard(_ReturnDisplayItem item) {
    final r = item.returnModel;
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
              builder: (_) => ReturnDetailMobilePage(returnId: r.id),
            ),
          ).then((_) => _loadReturns());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _shortId(r.id),
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
                    color: _statusColor(r.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(r.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(r.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 16, color: Color(0xff6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.productName,
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
                const Icon(Icons.person_outline,
                    size: 16, color: Color(0xff6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff374151),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatDate(r.returnDeadline.isNotEmpty
                      ? r.returnDeadline
                      : r.approvedAt.isNotEmpty
                          ? r.approvedAt
                          : ''),
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
          Icon(Icons.assignment_return_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pengajuan retur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada pengajuan retur yang ditemukan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
