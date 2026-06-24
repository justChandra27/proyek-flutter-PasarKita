import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../data/models/withdrawal_model.dart';

import 'withdrawal_detail_mobile_page.dart';

class _WithdrawalDisplayItem {
  final WithdrawalModel withdrawal;
  final String sellerName;
  final String storeName;

  _WithdrawalDisplayItem({
    required this.withdrawal,
    required this.sellerName,
    required this.storeName,
  });
}

class WithdrawalsMobilePage extends StatefulWidget {
  const WithdrawalsMobilePage({super.key});

  @override
  State<WithdrawalsMobilePage> createState() => _WithdrawalsMobilePageState();
}

class _WithdrawalsMobilePageState extends State<WithdrawalsMobilePage> {
  final Databases _db = AppwriteService.databases;
  final TextEditingController _searchController = TextEditingController();

  List<_WithdrawalDisplayItem> _allItems = [];
  List<_WithdrawalDisplayItem> _filteredItems = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'Semua';

  static const _filterOptions = [
    'Semua',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
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

  Future<void> _loadWithdrawals() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.withdrawalsCollectionId,
        queries: [
          Query.orderDesc('requestedAt'),
          Query.limit(100),
        ],
      );
      final withdrawals = result.documents.map((doc) {
        return WithdrawalModel.fromMap(doc.$id, doc.data);
      }).toList();

      final sellerIds = withdrawals
          .map((w) => w.sellerId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final sellerData = await _batchFetchSellerData(sellerIds);

      final items = withdrawals.map((w) {
        final data = sellerData[w.sellerId] ?? <String, String>{};
        return _WithdrawalDisplayItem(
          withdrawal: w,
          sellerName: data['name'] ?? 'Unknown',
          storeName: data['storeName'] ?? '',
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

  Future<Map<String, Map<String, String>>> _batchFetchSellerData(
      List<String> sellerIds) async {
    final map = <String, Map<String, String>>{};
    for (var i = 0; i < sellerIds.length; i += 100) {
      final chunk = sellerIds.sublist(
          i, (i + 100).clamp(0, sellerIds.length));
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('\$id', chunk)],
      );
      for (final doc in result.documents) {
        map[doc.$id] = {
          'name': doc.data['name'] as String? ?? 'Unknown',
          'storeName': doc.data['storeName'] as String? ?? '',
        };
      }
    }
    return map;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredItems = _allItems.where((item) {
        if (_selectedFilter != 'Semua') {
          if (item.withdrawal.status.toLowerCase() !=
              _selectedFilter.toLowerCase()) {
            return false;
          }
        }
        if (query.isNotEmpty) {
          final wId = item.withdrawal.id.toLowerCase();
          final seller = item.sellerName.toLowerCase();
          final store = item.storeName.toLowerCase();
          if (!wId.contains(query) &&
              !seller.contains(query) &&
              !store.contains(query)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
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
    return id.length > 8 ? 'WD-${id.substring(0, 8).toUpperCase()}' : 'WD-$id';
  }

  String _formatAmount(int amount) {
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
                onPressed: _loadWithdrawals,
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
                  onRefresh: _loadWithdrawals,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildWithdrawalCard(_filteredItems[index]);
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
          hintText: 'Cari seller, toko, atau ID withdrawal...',
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

  Widget _buildWithdrawalCard(_WithdrawalDisplayItem item) {
    final w = item.withdrawal;
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
              builder: (_) =>
                  WithdrawalDetailMobilePage(withdrawalId: w.id),
            ),
          ).then((_) => _loadWithdrawals());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _shortId(w.id),
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
                    color: _statusColor(w.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(w.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(w.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.store_outlined,
                    size: 16, color: Color(0xff6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.sellerName,
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
                const Icon(Icons.money,
                    size: 16, color: Color(0xff6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatAmount(w.amount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff111827),
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  _formatDate(w.requestedAt),
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
          Icon(Icons.account_balance_wallet,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada withdrawal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada withdrawal yang ditemukan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
