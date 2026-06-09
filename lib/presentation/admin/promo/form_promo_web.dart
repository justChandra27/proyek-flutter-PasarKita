import 'package:flutter/material.dart';

class FormPromoWeb extends StatelessWidget {
  const FormPromoWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari promo atau kode voucher...",
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

                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(width: 16),

                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Utama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Super Admin",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // TITLE
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manajemen Promo",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Kelola diskon, penawaran kilat, dan banner promosi Anda di sini.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Buat Promo Baru",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // STATISTIC
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.flash_on,
                    "Promo Aktif",
                    "12 Campaign",
                    Colors.blue,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.calendar_month_outlined,
                    "Mendatang",
                    "5 Campaign",
                    Colors.blueGrey,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.trending_up,
                    "Total Penggunaan",
                    "8.4k Kali",
                    Colors.grey,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.notifications_off_outlined,
                    "Berakhir Besok",
                    "2 Campaign",
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // TAB MENU
            const Row(
              children: [
                Text(
                  "Semua Promo",
                  style: TextStyle(
                    color: Color(0xff2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 30),
                Text("Voucher Belanja"),
                SizedBox(width: 30),
                Text("Diskon Produk"),
                SizedBox(width: 30),
                Text("Flash Sale"),
                SizedBox(width: 30),
                Text("Banner Beranda"),
              ],
            ),

            const Divider(height: 30),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // PROMO BERJALAN
                    Row(
                      children: [
                        const Text(
                          "Promo Sedang Berjalan",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffDBEAFE),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "LIVE",
                            style: TextStyle(
                              color: Color(0xff2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _promoCard(
                            title:
                                "Flash Sale Elektronik Akhir Bulan",
                            description:
                                "Diskon hingga 70% untuk kategori smartphone dan aksesoris.",
                            label: "FLASH SALE",
                            progress: 0.65,
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: _voucherCard(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // TABLE
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(
                          const Color(0xffF8F9FC),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text("Nama Promo"),
                          ),
                          DataColumn(
                            label: Text("Tipe"),
                          ),
                          DataColumn(
                            label: Text("Tanggal Mulai"),
                          ),
                          DataColumn(
                            label: Text("Status"),
                          ),
                          DataColumn(
                            label: Text("Aksi"),
                          ),
                        ],
                        rows: [
                          _promoRow(
                            "Mega Sale Ramadhan",
                            "Store-wide Discount",
                            "10 Mar 2024, 00:00",
                          ),
                          _promoRow(
                            "Free Ongkir Seluruh Indonesia",
                            "Logistic Promo",
                            "12 Mar 2024, 10:00",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                color.withValues(alpha: .15),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _promoCard({
    required String title,
    required String description,
    required String label,
    required double progress,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 170,
            decoration: const BoxDecoration(
              color: Color(0xff0F172A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xff2563EB),
                      borderRadius:
                          BorderRadius.circular(
                              8),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  LinearProgressIndicator(
                    value: progress,
                    borderRadius:
                        BorderRadius.circular(
                            10),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _voucherCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          "Voucher Pengguna Baru\nPASARKITA24",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  DataRow _promoRow(
    String name,
    String type,
    String date,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(type)),
        DataCell(Text(date)),
        DataCell(
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: const Text(
              "TERJADWAL",
            ),
          ),
        ),
        const DataCell(
          Text(
            "Detail",
            style: TextStyle(
              color: Color(0xff2563EB),
            ),
          ),
        ),
      ],
    );
  }
}