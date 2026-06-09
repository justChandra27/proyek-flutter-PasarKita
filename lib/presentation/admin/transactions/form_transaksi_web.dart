import 'package:flutter/material.dart';

class FormTransaksiWeb extends StatelessWidget {
  const FormTransaksiWeb({super.key});

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
                const Expanded(
                  child: Text(
                    "Transaksi",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 300,
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

                const SizedBox(width: 20),

                const VerticalDivider(),

                const SizedBox(width: 10),

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

            const SizedBox(height: 24),

            // STATISTIC CARD
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Total Pendapatan",
                    value: "Rp 128.450.000",
                    growth: "↑12.5%",
                    growthColor: Colors.green,
                    iconColor: Colors.blue,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.swap_horiz,
                    title: "Jumlah Transaksi",
                    value: "1,429",
                    growth: "↑8.2%",
                    growthColor: Colors.green,
                    iconColor: Colors.blueGrey,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.pending_actions,
                    title: "Transaksi Tertunda",
                    value: "42",
                    growth: "",
                    growthColor: Colors.transparent,
                    iconColor: Colors.orange,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.event_busy_outlined,
                    title: "Transaksi Gagal",
                    value: "12",
                    growth: "↓2.1%",
                    growthColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Riwayat Transaksi Terakhir",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Daftar transaksi real-time dari platform PasarKita",
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.filter_alt_outlined,
                            ),
                            label: const Text("Filter"),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff2563EB),
                            ),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Ekspor CSV",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(
                            const Color(0xffF8F9FC),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text("ID TRANSAKSI"),
                            ),
                            DataColumn(
                              label: Text("PELANGGAN"),
                            ),
                            DataColumn(
                              label: Text("METODE"),
                            ),
                            DataColumn(
                              label: Text("JUMLAH"),
                            ),
                            DataColumn(
                              label: Text("TANGGAL"),
                            ),
                            DataColumn(
                              label: Text("STATUS"),
                            ),
                            DataColumn(
                              label: Text("AKSI"),
                            ),
                          ],
                          rows: [
                            _transactionRow(
                              "#TRX-98231",
                              "BS",
                              "Budi Santoso",
                              "Transfer Bank",
                              "Rp 450.000",
                              "24 Okt 2023\n14:20 WIB",
                              "Berhasil",
                              Colors.green,
                            ),

                            _transactionRow(
                              "#TRX-98232",
                              "AN",
                              "Anita Nur",
                              "E-Wallet",
                              "Rp 1.200.000",
                              "24 Okt 2023\n15:05 WIB",
                              "Pending",
                              Colors.orange,
                            ),

                            _transactionRow(
                              "#TRX-98233",
                              "DR",
                              "Dedi Ramdan",
                              "Tunai",
                              "Rp 85.500",
                              "24 Okt 2023\n15:45 WIB",
                              "Berhasil",
                              Colors.green,
                            ),

                            _transactionRow(
                              "#TRX-98234",
                              "SM",
                              "Siti Maryam",
                              "Visa Card",
                              "Rp 2.450.000",
                              "24 Okt 2023\n16:12 WIB",
                              "Gagal",
                              Colors.red,
                            ),

                            _transactionRow(
                              "#TRX-98235",
                              "RP",
                              "Rizky Pratama",
                              "QRIS",
                              "Rp 125.000",
                              "24 Okt 2023\n17:00 WIB",
                              "Berhasil",
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Menampilkan 1–10 dari 1,429 transaksi",
                          ),
                          const Spacer(),

                          _pageButton("<", false),
                          _pageButton("1", true),
                          _pageButton("2", false),
                          _pageButton("3", false),

                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 8),
                            child: Text("..."),
                          ),

                          _pageButton("143", false),
                          _pageButton(">", false),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String growth,
    required Color growthColor,
    required Color iconColor,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    iconColor.withValues(alpha: .15),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const Spacer(),
              if (growth.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        growthColor.withValues(alpha: .12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    growth,
                    style: TextStyle(
                      color: growthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _transactionRow(
    String trxId,
    String avatar,
    String customer,
    String method,
    String amount,
    String date,
    String status,
    Color color,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            trxId,
            style: const TextStyle(
              color: Color(0xff2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    Colors.blue.withValues(alpha: .15),
                child: Text(
                  avatar,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(customer),
            ],
          ),
        ),

        DataCell(Text(method)),

        DataCell(
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        DataCell(Text(date)),

        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const DataCell(
          Icon(Icons.more_vert),
        ),
      ],
    );
  }

  static Widget _pageButton(
    String text,
    bool active,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xff2563EB)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}