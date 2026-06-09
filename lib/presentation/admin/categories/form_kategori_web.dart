import 'package:flutter/material.dart';

class FormKategoriWeb extends StatelessWidget {
  const FormKategoriWeb({super.key});

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
                    "Manajemen Kategori",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari kategori...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kelola klasifikasi produk Anda untuk memudahkan pencarian oleh pelanggan.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BUTTON
            Row(
              children: [
                const Spacer(),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff2563EB),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_circle_outline,
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

            // STAT CARD
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.grid_view_rounded,
                    title: "Total Kategori",
                    value: "12",
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.inventory_2_outlined,
                    title: "Total Produk",
                    value: "1,248",
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.warning_amber_rounded,
                    title: "Stok Menipis",
                    value: "34",
                    color: Colors.red,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.trending_up,
                    title: "Populer (Bulan Ini)",
                    value: "Elektronik",
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.78,
                children: const [
                  CategoryCard(
                    title: "Elektronik",
                    productCount: "245 Produk",
                    description:
                        "Perangkat digital, smartphone, laptop, dan aksesori elektronik.",
                  ),

                  CategoryCard(
                    title: "Fashion",
                    productCount: "512 Produk",
                    description:
                        "Pakaian pria, wanita, dan anak-anak dengan tren masa kini.",
                  ),

                  CategoryCard(
                    title: "Makanan",
                    productCount: "189 Produk",
                    description:
                        "Bahan makanan segar, camilan, dan minuman.",
                  ),

                  CategoryCard(
                    title: "Rumah Tangga",
                    productCount: "96 Produk",
                    description:
                        "Perabotan, dekorasi interior, dan perlengkapan rumah.",
                  ),

                  CategoryCard(
                    title: "Kecantikan",
                    productCount: "124 Produk",
                    description:
                        "Produk perawatan wajah, tubuh, dan alat kesehatan.",
                  ),

                  CategoryCard(
                    title: "Olahraga",
                    productCount: "78 Produk",
                    description:
                        "Alat fitness, perlengkapan outdoor, dan pakaian olahraga.",
                  ),

                  AddCategoryCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
            radius: 22,
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
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String productCount;
  final String description;

  const CategoryCard({
    super.key,
    required this.title,
    required this.productCount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
              ),

              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xff2563EB),
                    borderRadius:
                        BorderRadius.circular(
                            8),
                  ),
                  child: Text(
                    productCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.more_vert,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  description,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                  0xffF1F5F9),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Lihat Detail",
                          style: TextStyle(
                            color:
                                Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddCategoryCard extends StatelessWidget {
  const AddCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey.shade200,
          width: 1.5,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                Color(0xffF1F5F9),
            child: Icon(
              Icons.add,
              size: 30,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Tambah Kategori",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Definisikan segmen baru",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}