//lib/presentation/seller/categories/form_kategori_seller_web.dart

import 'package:flutter/material.dart';

class FormKategoriSellerWeb extends StatelessWidget {
  const FormKategoriSellerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari kategori...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Andi Setiawan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Verified Merchant",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // TITLE
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manajemen Kategori",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Atur pengelompokan produk Anda untuk pengalaman belanja yang lebih baik.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1D4ED8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Tambah Kategori Baru",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.2,
                            children: [
                              _categoryCard(
                                icon: Icons.checkroom,
                                iconColor: Colors.blue,
                                title: "Pakaian",
                                description:
                                    "Atasan, bawahan, outerwear, dan pakaian tradisional.",
                                totalProduct: "1,240",
                                status: "Aktif",
                                statusColor: Colors.green,
                              ),

                              _categoryCard(
                                icon: Icons.computer,
                                iconColor: Colors.brown,
                                title: "Elektronik",
                                description:
                                    "Gadget, aksesoris komputer, dan peralatan rumah elektronik.",
                                totalProduct: "856",
                                status: "Aktif",
                                statusColor: Colors.green,
                              ),

                              _categoryCard(
                                icon: Icons.home,
                                iconColor: Colors.green,
                                title: "Rumah Tangga",
                                description:
                                    "Perabotan, dekorasi, dan perlengkapan dapur.",
                                totalProduct: "532",
                                status: "Aktif",
                                statusColor: Colors.green,
                              ),

                              _categoryCard(
                                icon: Icons.face,
                                iconColor: Colors.red,
                                title: "Kecantikan",
                                description:
                                    "Skincare, makeup, dan perawatan rambut.",
                                totalProduct: "312",
                                status: "Draft",
                                statusColor: Colors.blueGrey,
                              ),

                              _categoryCard(
                                icon: Icons.restaurant,
                                iconColor: Colors.orange,
                                title: "Kuliner",
                                description:
                                    "Camilan khas, bumbu dapur, dan minuman segar.",
                                totalProduct: "98",
                                status: "Aktif",
                                statusColor: Colors.green,
                              ),

                              _addCategoryCard(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _performanceCard(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  SizedBox(
                    width: 250,
                    child: _tipsCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String totalProduct,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withValues(alpha: .15),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Colors.black54,
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Text(
                totalProduct,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 5),

              const Text("Produk"),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addCategoryCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey.shade200,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xffDBEAFE),
            child: Icon(
              Icons.add,
              size: 30,
              color: Color(0xff1D4ED8),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Kategori Baru",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Mulai kelompokkan produk baru Anda",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _performanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performa Kategori",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _performanceItem(
                  "Kategori Terpopuler",
                  "Pakaian",
                  Colors.blue,
                ),
              ),

              Expanded(
                child: _performanceItem(
                  "Pertumbuhan Tertinggi",
                  "Elektronik",
                  Colors.green,
                ),
              ),

              Expanded(
                child: _performanceItem(
                  "Stok Menipis",
                  "Kuliner",
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceItem(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: .6,
          color: color,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1D4ED8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tips Optimasi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "Gunakan nama kategori yang umum dicari pembeli untuk meningkatkan visibilitas produk Anda di hasil pencarian.",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}