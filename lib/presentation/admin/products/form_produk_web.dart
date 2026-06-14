import 'package:flutter/material.dart';

import '../../../core/services/product_service_appwrite.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/moderation_status.dart';
import 'product_moderation_card.dart';
import 'moderation_dialog.dart';

class FormProdukWeb extends StatefulWidget {
  const FormProdukWeb({super.key});

  @override
  State<FormProdukWeb> createState() => _FormProdukWebState();
}

class _FormProdukWebState extends State<FormProdukWeb> {
  final _service = ProductServiceAppwrite();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _adminName = 'Admin';

  String _selectedTab = 'Semua';
  static const _tabs = ['Semua', 'Pending', 'Approved', 'Rejected', 'Deactivated'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadAdminName();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _service.getAllProductsForAdmin();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAdminName() async {
    try {
      final userData = await AuthServiceAppwrite().getCurrentUserData();
      if (mounted && userData != null) {
        setState(() => _adminName = userData['name'] ?? 'Admin');
      }
    } catch (_) {}
  }

  void _setTab(String tab) {
    setState(() {
      _selectedTab = tab;
      _applyFilters();
    });
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery) &&
          !p.category.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      if (_selectedTab != 'Semua') {
        final tabStatus = _selectedTab.toLowerCase();
        if (p.moderationStatus != tabStatus) return false;
      }
      return true;
    }).toList();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu';
      case 'deactivated':
        return 'Nonaktif';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'deactivated':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  int _countByStatus(String status) {
    if (status == 'Semua') return _allProducts.length;
    return _allProducts.where((p) => p.moderationStatus == status.toLowerCase()).length;
  }

  Future<void> _approve(ProductModel product) async {
    try {
      await _service.updateModerationStatus(
        productId: product.id,
        status: ModerationStatus.approved,
        moderatedBy: _adminName,
      );
      _showSnackBar('${product.name} telah disetujui', Colors.green);
      _loadProducts();
    } catch (e) {
      _showSnackBar('Gagal menyetujui: $e', Colors.red);
    }
  }

  Future<void> _reject(ProductModel product) async {
    final note = await showModerationDialog(
      context,
      title: 'Tolak ${product.name}',
      actionLabel: 'Tolak',
      actionColor: Colors.red,
    );
    if (note == null) return;
    try {
      await _service.updateModerationStatus(
        productId: product.id,
        status: ModerationStatus.rejected,
        moderatedBy: _adminName,
        moderationNote: note,
      );
      _showSnackBar('${product.name} telah ditolak', Colors.red);
      _loadProducts();
    } catch (e) {
      _showSnackBar('Gagal menolak: $e', Colors.red);
    }
  }

  Future<void> _deactivate(ProductModel product) async {
    final note = await showModerationDialog(
      context,
      title: 'Nonaktifkan ${product.name}',
      actionLabel: 'Nonaktifkan',
      actionColor: Colors.orange,
    );
    if (note == null) return;
    try {
      await _service.updateModerationStatus(
        productId: product.id,
        status: ModerationStatus.deactivated,
        moderatedBy: _adminName,
        moderationNote: note,
      );
      _showSnackBar('${product.name} telah dinonaktifkan', Colors.orange);
      _loadProducts();
    } catch (e) {
      _showSnackBar('Gagal menonaktifkan: $e', Colors.red);
    }
  }

  Future<void> _reactivate(ProductModel product) async {
    try {
      await _service.updateModerationStatus(
        productId: product.id,
        status: ModerationStatus.approved,
        moderatedBy: _adminName,
        moderationNote: '',
      );
      _showSnackBar('${product.name} telah diaktifkan kembali', Colors.green);
      _loadProducts();
    } catch (e) {
      _showSnackBar('Gagal mengaktifkan: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatCards(),
            const SizedBox(height: 20),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Manajemen Produk',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 320,
          child: TextField(
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Cari nama produk...',
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
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,
          child: Text(
            _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return SizedBox(
      height: 80,
      child: Row(
        children: _tabs.map((tab) {
          final count = _countByStatus(tab);
          final isActive = _selectedTab == tab;
          final color = tab == 'Semua'
              ? const Color(0xff2563EB)
              : _statusColor(tab.toLowerCase());
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => _setTab(tab),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? color : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? color : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        tab == 'Semua' ? 'Semua Produk' : _statusLabel(tab.toLowerCase()),
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _tabButton('Semua'),
        const SizedBox(width: 8),
        _tabButton('Pending'),
        const SizedBox(width: 8),
        _tabButton('Approved'),
        const SizedBox(width: 8),
        _tabButton('Rejected'),
        const SizedBox(width: 8),
        _tabButton('Deactivated'),
        const Spacer(),
        Text(
          '${_filteredProducts.length} produk',
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _tabButton(String tab) {
    final isActive = _selectedTab == tab;
    final color = tab == 'Semua'
        ? const Color(0xff2563EB)
        : _statusColor(tab.toLowerCase());
    return GestureDetector(
      onTap: () => _setTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
          ),
        ),
        child: Text(
          tab,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Produk tidak ditemukan'
                  : 'Tidak ada produk dengan status ini',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductModerationCard(
          product: product,
          adminName: _adminName,
          onApprove: () => _approve(product),
          onReject: () => _reject(product),
          onDeactivate: () => _deactivate(product),
          onReactivate: () => _reactivate(product),
        );
      },
    );
  }
}
