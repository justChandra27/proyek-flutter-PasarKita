//lib/presentation/admin/orders/form_pesanan_web.dart
//Elsyana
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import '../../../core/services/order_service_appwrite.dart';

class FormPesananWeb extends StatelessWidget {
  const FormPesananWeb({super.key});

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
                        hintText: "Cari pesanan atau pelanggan...",
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
                      "Administrator",
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Pesanan",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Pantau dan kelola semua pesanan pelanggan Anda.",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACTION BUTTON
            Row(
              children: [
                const Spacer(),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text("Filter"),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
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

            const SizedBox(height: 24),

            // STAT CARD
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.shopping_cart_outlined,
                    "TOTAL PESANAN",
                    "1,284",
                    const Color(0xff2563EB),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.pending_actions,
                    "PENDING",
                    "43",
                    Colors.orange,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.local_shipping_outlined,
                    "DIKIRIM",
                    "156",
                    Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.check_circle_outline,
                    "SELESAI",
                    "1,085",
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // TABLE
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(
                            const Color(0xffF8F9FC),
                          ),
                          columns: const [
                            DataColumn(label: Text("Order ID")),
                            DataColumn(label: Text("Pelanggan")),
                            DataColumn(label: Text("Tanggal")),
                            DataColumn(label: Text("Total Amount")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Aksi")),
                          ],
                          rows: [
                            _orderRow(
                              "#ORD-2023-8942",
                              "AD",
                              "Ahmad Dani",
                              "24 Okt 2023, 14:20",
                              "Rp 1.250.000",
                              "Pending",
                              Colors.orange,
                            ),

                            _orderRow(
                              "#ORD-2023-8941",
                              "SA",
                              "Siti Aminah",
                              "24 Okt 2023, 11:05",
                              "Rp 450.000",
                              "Shipped",
                              Colors.blue,
                            ),

                            _orderRow(
                              "#ORD-2023-8940",
                              "BK",
                              "Budi Kusuma",
                              "23 Okt 2023, 16:45",
                              "Rp 2.100.000",
                              "Completed",
                              Colors.green,
                            ),

                            _orderRow(
                              "#ORD-2023-8939",
                              "RP",
                              "Rian Pratama",
                              "23 Okt 2023, 09:12",
                              "Rp 890.000",
                              "Completed",
                              Colors.green,
                            ),

                            _orderRow(
                              "#ORD-2023-8938",
                              "DW",
                              "Dewi Wijaya",
                              "22 Okt 2023, 19:30",
                              "Rp 125.000",
                              "Cancelled",
                              Colors.red,
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
                            "Menampilkan 1–5 dari 1,284 pesanan",
                          ),
                          const Spacer(),
                          _pageButton("<", false),
                          _pageButton("1", true),
                          _pageButton("2", false),
                          _pageButton("3", false),
                          _pageButton(">", false),
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
      height: 100,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  DataRow _orderRow(
    String orderId,
    String avatar,
    String customer,
    String date,
    String total,
    String status,
    Color color,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            orderId,
            style: const TextStyle(
              color: Color(0xff2563EB),
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

        DataCell(Text(date)),

        DataCell(
          Text(
            total,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

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