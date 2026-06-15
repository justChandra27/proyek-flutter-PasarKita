// lib/presentation/admin/transactions/form_transaksi_web.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/transaksi_controller.dart';
import '../../../data/models/transaksi_model.dart';

class FormTransaksiWeb extends StatefulWidget {
  const FormTransaksiWeb({super.key});

  @override
  State<FormTransaksiWeb> createState() => _FormTransaksiWebState();
}

class _FormTransaksiWebState extends State<FormTransaksiWeb> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransaksiController>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiController>(
      builder: (context, ctrl, _) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F6FA),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeader(ctrl),
                const SizedBox(height: 24),
                _buildStatCards(ctrl),
                const SizedBox(height: 24),
                Expanded(child: _buildTable(ctrl)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────
  Widget _buildHeader(TransaksiController ctrl) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Transaksi",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            onChanged: ctrl.search,
            decoration: InputDecoration(
              hintText: "Cari transaksi...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ctrl.search('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        const VerticalDivider(),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Admin Utama", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Super Admin",
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  // ─── STAT CARDS ──────────────────────────────────────────────────────────
  Widget _buildStatCards(TransaksiController ctrl) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.account_balance_wallet_outlined,
            title: "Total Pendapatan",
            value: ctrl.formatRupiah(ctrl.totalPendapatan),
            iconColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.swap_horiz,
            title: "Jumlah Transaksi",
            value: ctrl.jumlahTransaksi.toString(),
            iconColor: Colors.blueGrey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.pending_actions,
            title: "Transaksi Tertunda",
            value: ctrl.transaksiPending.toString(),
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.event_busy_outlined,
            title: "Transaksi Gagal",
            value: ctrl.transaksiGagal.toString(),
            iconColor: Colors.red,
          ),
        ),
      ],
    );
  }

  // ─── TABEL ───────────────────────────────────────────────────────────────
  Widget _buildTable(TransaksiController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildTableHeader(ctrl),
          const Divider(height: 1),
          Expanded(child: _buildTableBody(ctrl)),
          _buildPagination(ctrl),
        ],
      ),
    );
  }

  Widget _buildTableHeader(TransaksiController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Riwayat Transaksi Terakhir",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Daftar transaksi real-time dari platform PasarKita",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          PopupMenuButton<String?>(
            initialValue: ctrl.statusFilter,
            onSelected: ctrl.filterStatus,
            itemBuilder: (_) => const [
              PopupMenuItem(value: '', child: Text("Semua")),
              PopupMenuItem(value: 'berhasil', child: Text("Berhasil")),
              PopupMenuItem(value: 'pending', child: Text("Pending")),
              PopupMenuItem(value: 'gagal', child: Text("Gagal")),
            ],
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.filter_alt_outlined),
              label: Text(ctrl.statusFilter == null
                  ? "Filter"
                  : _filterLabel(ctrl.statusFilter!)),
            ),
          ),
          const SizedBox(width: 12),
          Visibility(
            visible: false,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563EB)),
              onPressed: () {},
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text("Ekspor CSV",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(TransaksiController ctrl) {
    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ctrl.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(ctrl.errorMessage!,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: ctrl.loadTransaksi,
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    if (ctrl.transaksiList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: Colors.black26),
            SizedBox(height: 12),
            Text("Belum ada transaksi",
                style: TextStyle(color: Colors.black45)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: 80,
              horizontalMargin: 24,
              headingRowColor:
                  WidgetStateProperty.all(const Color(0xffF8F9FC)),
              columns: const [
                DataColumn(label: Text("ID TRANSAKSI")),
                DataColumn(label: Text("PELANGGAN")),
                DataColumn(label: Text("METODE")),
                DataColumn(label: Text("JUMLAH")),
                DataColumn(label: Text("TANGGAL")),
                DataColumn(label: Text("STATUS")),
                DataColumn(label: Text("AKSI")),
              ],
              rows: ctrl.transaksiList
                  .map((trx) => _buildRow(trx, ctrl))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(TransaksiModel trx, TransaksiController ctrl) {
    final statusColor = _statusColor(trx.status);
    return DataRow(cells: [
      DataCell(Text(
        '#${trx.id.length >= 8 ? trx.id.substring(0, 8).toUpperCase() : trx.id.toUpperCase()}',
        style: const TextStyle(
            color: Color(0xff2563EB), fontWeight: FontWeight.w600),
      )),
      DataCell(Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.withOpacity(.15),
          child: Text(trx.avatarInitials,
              style: const TextStyle(fontSize: 11)),
        ),
        const SizedBox(width: 10),
        Text(trx.customerName),
      ])),
      DataCell(Text(trx.metodeLabel)),
      DataCell(Text(ctrl.formatRupiah(trx.jumlah),
          style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(_formatDate(trx.createdAt))),
      DataCell(Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(trx.statusLabel,
            style: TextStyle(
                color: statusColor, fontWeight: FontWeight.w600)),
      )),
      DataCell(IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showDetail(context, trx, ctrl),
      )),
    ]);
  }

  // ─── PAGINATION ──────────────────────────────────────────────────────────
  Widget _buildPagination(TransaksiController ctrl) {
    if (ctrl.totalPages <= 1) return const SizedBox.shrink();

    final from = ((ctrl.currentPage - 1) * ctrl.perPage) + 1;
    final to =
        (ctrl.currentPage * ctrl.perPage).clamp(0, ctrl.totalData);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Text(
            "Menampilkan $from–$to dari ${ctrl.totalData} transaksi",
            style: const TextStyle(color: Colors.black54),
          ),
          const Spacer(),
          _pageButton("<", false, onTap: ctrl.prevPage),
          _pageButton("1", ctrl.currentPage == 1,
              onTap: () => ctrl.goToPage(1)),
          if (ctrl.currentPage > 2 &&
              ctrl.currentPage < ctrl.totalPages)
            _pageButton(ctrl.currentPage.toString(), true,
                onTap: null),
          if (ctrl.totalPages > 3)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("..."),
            ),
          if (ctrl.totalPages > 1)
            _pageButton(
              ctrl.totalPages.toString(),
              ctrl.currentPage == ctrl.totalPages,
              onTap: () => ctrl.goToPage(ctrl.totalPages),
            ),
          _pageButton(">", false, onTap: ctrl.nextPage),
        ],
      ),
    );
  }

  // ─── DETAIL DIALOG ───────────────────────────────────────────────────────
  void _showDetail(
      BuildContext context, TransaksiModel trx, TransaksiController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            'Detail #${trx.id.length >= 8 ? trx.id.substring(0, 8).toUpperCase() : trx.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Pelanggan", trx.customerName),
            _detailRow("Metode", trx.metodeLabel),
            _detailRow("Jumlah", ctrl.formatRupiah(trx.jumlah)),
            _detailRow("Status", trx.statusLabel),
            _detailRow("Tanggal", _formatDateFull(trx.createdAt)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup")),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'berhasil': return Colors.green;
      case 'pending':  return Colors.orange;
      case 'gagal':    return Colors.red;
      default:         return Colors.grey;
    }
  }

  String _filterLabel(String status) {
    switch (status) {
      case 'berhasil': return 'Berhasil';
      case 'pending':  return 'Pending';
      case 'gagal':    return 'Gagal';
      default:         return status;
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['','Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${dt.day} ${months[dt.month]} ${dt.year}\n'
        '${dt.hour.toString().padLeft(2,'0')}:'
        '${dt.minute.toString().padLeft(2,'0')} WIB';
  }

  String _formatDateFull(DateTime dt) {
    const months = ['','Januari','Februari','Maret','April','Mei',
                    'Juni','Juli','Agustus','September','Oktober',
                    'November','Desember'];
    return '${dt.day} ${months[dt.month]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2,'0')}:'
        '${dt.minute.toString().padLeft(2,'0')} WIB';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: Colors.black54))),
        const Text(": "),
        Expanded(child: Text(value)),
      ]),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(.15),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static Widget _pageButton(String text, bool active,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? const Color(0xff2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  color:
                      active ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }
}