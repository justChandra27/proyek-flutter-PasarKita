
import 'package:flutter/material.dart';

class PesananCustomerWeb extends StatelessWidget {
  const PesananCustomerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari pesanan...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                const Icon(
                  Icons.notifications_none,
                  color: Colors.black54,
                ),

                const SizedBox(width: 16),

                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pesanan Saya",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TAB FILTER
            Row(
              children: [
                _tabButton("Semua", true),
                const SizedBox(width: 10),
                _tabButton("Berjalan", false),
                const SizedBox(width: 10),
                _tabButton("Selesai", false),
                const SizedBox(width: 10),
                _tabButton("Dibatalkan", false),
              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: const [
                  _OrderCard(
                    invoice:
                        "INV/20231024/MPL/3512941",
                    status: "Sedang Dikirim",
                    amount: "Rp 450.000",
                    date: "24 Okt 2023",
                    product:
                        "Jaket Puff Premium Olive",
                    detail:
                        "1 Barang x Rp 450.000",
                    buttonText:
                        "Lacak Pesanan",
                    primary: true,
                  ),

                  SizedBox(height: 16),

                  _OrderCard(
                    invoice:
                        "INV/20231020/MPL/3512800",
                    status: "Selesai",
                    amount: "Rp 250.000",
                    date: "20 Okt 2023",
                    product:
                        "Baju Kaos Band Premium",
                    detail:
                        "1 Barang x Rp 250.000",
                    buttonText:
                        "Beli Lagi",
                    primary: false,
                  ),

                  SizedBox(height: 16),

                  _OrderCard(
                    invoice:
                        "INV/20231015/MPL/3512750",
                    status: "Selesai",
                    amount: "Rp 1.150.000",
                    date: "15 Okt 2023",
                    product:
                        "Sepatu Sport X-Grip Red",
                    detail:
                        "1 Barang (+2 barang lainnya)",
                    buttonText:
                        "Beli Lagi",
                    primary: false,
                    showDetailButton: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tabButton(
    String text,
    bool active,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xff2563EB)
            : const Color(0xffDBEAFE),
        borderRadius:
            BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String invoice;
  final String status;
  final String amount;
  final String date;
  final String product;
  final String detail;
  final String buttonText;
  final bool primary;
  final bool showDetailButton;

  const _OrderCard({
    required this.invoice,
    required this.status,
    required this.amount,
    required this.date,
    required this.product,
    required this.detail,
    required this.buttonText,
    required this.primary,
    this.showDetailButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        status == "Selesai"
            ? Colors.green
            : const Color(0xff2563EB);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    statusColor.withValues(alpha: .15),
                child: Icon(
                  status == "Selesai"
                      ? Icons.check_circle
                      : Icons.local_shipping,
                  color: statusColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Color(0xff2563EB),
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail,
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                if (showDetailButton)
                  Container(
                    margin:
                        const EdgeInsets.only(
                            right: 10),
                    child: OutlinedButton(
                      onPressed: () {},
                      child:
                          const Text("Detail"),
                    ),
                  ),

                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: primary
                        ? const Color(
                            0xff2563EB)
                        : Colors.white,
                    foregroundColor: primary
                        ? Colors.white
                        : const Color(
                            0xff2563EB),
                    side: BorderSide(
                      color: primary
                          ? const Color(
                              0xff2563EB)
                          : const Color(
                              0xff2563EB),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {},
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}