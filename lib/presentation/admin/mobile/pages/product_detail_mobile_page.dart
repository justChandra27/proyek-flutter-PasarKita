import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/services/product_service_appwrite.dart';
import '../../../../core/services/auth_service_appwrite.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/moderation_status.dart';

class ProductDetailMobilePage extends StatefulWidget {
  final String productId;

  const ProductDetailMobilePage({super.key, required this.productId});

  @override
  State<ProductDetailMobilePage> createState() =>
      _ProductDetailMobilePageState();
}

class _ProductDetailMobilePageState extends State<ProductDetailMobilePage> {
  final ProductServiceAppwrite _productService = ProductServiceAppwrite();
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  final Databases _db = AppwriteService.databases;

  ProductModel? _product;
  String _sellerName = '';
  String _adminId = '';
  bool _loading = true;
  String? _error;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await _productService.getProductById(widget.productId);
      if (!mounted) return;
      if (product == null) {
        setState(() {
          _error = 'Produk tidak ditemukan';
          _loading = false;
        });
        return;
      }

      String sellerName = '';
      if (product.sellerId.isNotEmpty) {
        try {
          final usersResult = await _db.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollectionId,
            queries: [Query.equal('uid', product.sellerId)],
          );
          if (usersResult.documents.isNotEmpty) {
            final userData = usersResult.documents.first.data;
            sellerName = (userData['storeName'] as String?) ??
                (userData['name'] as String?) ??
                '';
          }
        } catch (_) {}
      }

      String adminId = '';
      try {
        final adminData = await _authService.getCurrentUserData();
        if (adminData != null) {
          adminId = adminData['uid'] as String? ??
              adminData['\$id'] as String? ??
              '';
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _product = product;
        _sellerName = sellerName;
        _adminId = adminId;
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

  Future<void> _approveProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menyetujui produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_product == null || _adminId.isEmpty) return;

    setState(() => _actionLoading = true);
    try {
      await _productService.updateModerationStatus(
        productId: _product!.id,
        status: ModerationStatus.approved,
        moderatedBy: _adminId,
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _rejectProduct() async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yakin ingin menolak produk ini?'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Alasan penolakan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (_product == null || _adminId.isEmpty) return;

    final reason = noteController.text.trim();
    if (reason.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi alasan penolakan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _actionLoading = true);
    try {
      await _productService.updateModerationStatus(
        productId: _product!.id,
        status: ModerationStatus.rejected,
        moderatedBy: _adminId,
        moderationNote: reason,
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Color _moderationColor(String status) {
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

  String _moderationLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatPrice(double price) {
    final p = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text('Detail Produk',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _product!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPhotoSection(p),
            const SizedBox(height: 12),
            _buildInfoCard('Informasi Produk', [
              _infoRow(Icons.shopping_bag, 'Nama Produk', p.name),
              if (_sellerName.isNotEmpty)
                _infoRow(Icons.store, 'Seller', _sellerName),
              _infoRow(Icons.category, 'Kategori', p.category),
              _infoRow(Icons.monetization_on, 'Harga', _formatPrice(p.price)),
              _infoRow(Icons.inventory, 'Stok', '${p.stock}'),
              _infoRow(Icons.monitor_weight, 'Berat', '${p.weight} gr'),
              _infoRow(
                  Icons.shopping_cart_checkout, 'Min. Pembelian', '${p.minPurchase}'),
              if (p.description.isNotEmpty)
                _infoRow(Icons.notes, 'Deskripsi', p.description),
            ]),
            const SizedBox(height: 12),
            _buildModerationInfoCard(p),
            if (p.moderationStatus.toLowerCase() == 'pending') ...[
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
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
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xff111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(ProductModel p) {
    final urls = p.imageUrl
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (urls.isEmpty) {
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
              'Galeri Foto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff111827),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        size: 28, color: Colors.grey.shade400),
                    const SizedBox(height: 4),
                    Text(
                      'Tidak ada foto produk',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

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
            'Galeri Foto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          if (urls.length > 1)
            SizedBox(
              height: 220,
              child: PageView(
                children: urls.map((url) => _buildPhotoItem(url)).toList(),
              ),
            )
          else
            _buildPhotoItem(urls.first),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image,
                      size: 32, color: Colors.red.shade300),
                  const SizedBox(height: 4),
                  Text(
                    'Gagal memuat gambar',
                    style: TextStyle(
                        fontSize: 12, color: Colors.red.shade400),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModerationInfoCard(ProductModel p) {
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
            'Informasi Moderasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            Icons.gavel,
            'Status',
            _moderationLabel(p.moderationStatus),
            valueColor: _moderationColor(p.moderationStatus),
          ),
          _infoRow(Icons.access_time, 'Dimoderasi',
              p.moderatedAt != null ? _formatDate(p.moderatedAt.toString()) : '-'),
          if (p.moderatedBy.isNotEmpty)
            _infoRow(Icons.person, 'Oleh', p.moderatedBy),
          if (p.moderationNote.isNotEmpty)
            _infoRow(Icons.comment, 'Catatan', p.moderationNote),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _actionLoading ? null : _rejectProduct,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close),
              label: const Text('Tolak Produk'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _actionLoading ? null : _approveProduct,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Setujui Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
