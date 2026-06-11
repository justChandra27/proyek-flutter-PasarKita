//lib/presentation/customer/profile/profile_customer_web.dart

import 'package:flutter/material.dart';

class ProfileCustomerWeb extends StatelessWidget {
  const ProfileCustomerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Akun Saya",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2563EB),
                    ),
                  ),
                ),

                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage:
                            NetworkImage(
                          "https://i.pravatar.cc/300",
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding:
                              const EdgeInsets.all(
                                  5),
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xff2563EB),
                            shape:
                                BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color:
                                Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Adrian Wijaya",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Gold Member • Sejak 2022",
                          style: TextStyle(
                            color:
                                Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _statCard(
                    "12",
                    "PESANAN",
                  ),

                  const SizedBox(width: 12),

                  _statCard(
                    "Rp 4.2M",
                    "TRANSAKSI",
                  ),

                  const SizedBox(width: 12),

                  _statCard(
                    "250",
                    "POIN",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // INFORMASI PRIBADI
            Container(
              padding: const EdgeInsets.all(20),
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
                      const Text(
                        "Informasi Pribadi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Ubah Semua",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          "NAMA LENGKAP",
                          "Adrian Wijaya",
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _inputField(
                          "ALAMAT EMAIL",
                          "adrian.wijaya@example.com",
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _inputField(
                          "NOMOR TELEPON",
                          "+62 812 3456 7890",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          "TANGGAL LAHIR",
                          "08/24/1995",
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child:
                            _dropdownField(
                          "JENIS KELAMIN",
                          "Laki-laki",
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _inputField(
                          "PEKERJAAN",
                          "Software Engineer",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Divider(),

                  const SizedBox(height: 20),

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child:
                          ElevatedButton(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xff2563EB),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Simpan Perubahan",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ALAMAT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Alamat Pengiriman Utama",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _inputField(
                          "ALAMAT LENGKAP",
                          "Jl. Sudirman No.123, Kebayoran Baru, Jakarta Selatan",
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _inputField(
                          "KODE POS",
                          "12190",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(
    String value,
    String title,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
              color: Color(0xff2563EB),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _inputField(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller:
              TextEditingController(
            text: value,
          ),
          decoration: InputDecoration(
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _dropdownField(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: const [
            DropdownMenuItem(
              value: "Laki-laki",
              child: Text(
                "Laki-laki",
              ),
            ),
            DropdownMenuItem(
              value: "Perempuan",
              child: Text(
                "Perempuan",
              ),
            ),
          ],
          onChanged: (value) {},
          decoration: InputDecoration(
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
            ),
          ),
        ),
      ],
    );
  }
}