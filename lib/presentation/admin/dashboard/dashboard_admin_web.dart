//lib/presentation/admin/dashboard/dashboard_admin_web.dart

import 'package:flutter/material.dart';


class DashboardAdminWeb extends StatelessWidget {
  const DashboardAdminWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              _buildStatCards(),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildSalesChart()),

                  const SizedBox(width: 20),

                  Expanded(child: _buildActivityCard()),
                ],
              ),

              const SizedBox(height: 24),

              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Ringkasan Dashboard",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Cari transaksi...",
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

        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Total Pengguna",
            "12,543",
            "+12%",
            Icons.people_outline,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            "Total Pesanan",
            "1,892",
            "+5%",
            Icons.shopping_bag_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            "Pendapatan",
            "Rp 84.2M",
            "-2%",
            Icons.payments_outlined,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: _statCard(
            "Total Produk",
            "4,320",
            "+8%",
            Icons.inventory_2_outlined,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String growth,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(growth, style: const TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ikhtisar Penjualan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),

          const Text("Data penjualan 7 hari terakhir"),

          const SizedBox(height: 40),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(120, false),
                _bar(190, false),
                _bar(90, true),
                _bar(220, false),
                _bar(110, false),
                _bar(160, false),
                _bar(200, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, bool active) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: active ? const Color(0xff2563EB) : Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aktivitas Terbaru",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          SizedBox(height: 20),

          ListTile(
            leading: Icon(Icons.circle, size: 10, color: Colors.blue),
            title: Text("Pesanan baru #TRX-9921"),
            subtitle: Text("2 menit lalu"),
          ),

          ListTile(
            leading: Icon(Icons.circle, size: 10, color: Colors.green),
            title: Text("Verifikasi merchant berhasil"),
            subtitle: Text("15 menit lalu"),
          ),

          ListTile(
            leading: Icon(Icons.circle, size: 10, color: Colors.orange),
            title: Text("Produk baru ditambahkan"),
            subtitle: Text("1 jam lalu"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(Icons.person_add_alt, "Verifikasi User"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionButton(Icons.add_box_outlined, "Tambah Produk"),
          ),
          const SizedBox(width: 16),
          Expanded(child: _actionButton(Icons.campaign_outlined, "Buat Promo")),
          const SizedBox(width: 16),
          Expanded(child: _actionButton(Icons.download, "Export Laporan")),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String title) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xffF5F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }
}
