import 'package:flutter/material.dart';

class FormPenggunaWeb extends StatelessWidget {
  const FormPenggunaWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Kelola Pengguna",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari data...",
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

                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                const Text(
                  "Admin Utama",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Statistik
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Total Pengguna",
                    "1,284",
                    Icons.people_alt_outlined,
                    const Color(0xff2563EB),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    "Pengguna Aktif",
                    "942",
                    Icons.person_add_alt,
                    const Color(0xff22C55E),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    "Baru (Bulan Ini)",
                    "52",
                    Icons.person_add_outlined,
                    const Color(0xffEAB308),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    "Ditangguhkan",
                    "12",
                    Icons.person_off_outlined,
                    const Color(0xffEF4444),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                                  "Daftar Pengguna",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Kelola dan tinjau hak akses pengguna platform Anda.",
                                ),
                              ],
                            ),
                          ),

                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.filter_list),
                            label: const Text("Filter"),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff2563EB),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text(
                              "Tambah Pengguna",
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
                            const Color(0xffF9FAFB),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                "NAMA LENGKAP",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "EMAIL",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "ROLE",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "STATUS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "AKSI",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            _userRow(
                              "AD",
                              "Ahmad Dahlan",
                              "ahmad.dahlan@example.com",
                              "Admin",
                              "Aktif",
                              Colors.green,
                            ),
                            _userRow(
                              "SA",
                              "Siti Aminah",
                              "siti.aminah@shop.com",
                              "Penjual",
                              "Aktif",
                              Colors.green,
                            ),
                            _userRow(
                              "BP",
                              "Budi Pratama",
                              "budi.p@gmail.com",
                              "Pembeli",
                              "Nonaktif",
                              Colors.grey,
                            ),
                            _userRow(
                              "RE",
                              "Rina Eka",
                              "rina.eka@domain.id",
                              "Penjual",
                              "Ditangguhkan",
                              Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Menampilkan 1 - 4 dari 1,284 pengguna",
                          ),

                          const Spacer(),

                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(10),
                              color: const Color(0xff2563EB),
                            ),
                            child: const Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),
                          const Text("2"),
                          const SizedBox(width: 10),
                          const Text("3"),
                        ],
                      ),
                    )
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
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(20),
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

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(title),
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

  DataRow _userRow(
    String avatar,
    String name,
    String email,
    String role,
    String status,
    Color statusColor,
  ) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    Colors.blue.withValues(alpha: .2),
                child: Text(
                  avatar,
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(name),
            ],
          ),
        ),
        DataCell(Text(email)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role),
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}