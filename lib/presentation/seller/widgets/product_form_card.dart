import 'package:flutter/material.dart';

class ProductFormCard extends StatelessWidget {
  const ProductFormCard({super.key});

  @override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffEAF2FF),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xff2962FF),
                ),
              ),

              const SizedBox(width: 12),

              const Text(
                "Informasi Produk",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // NAMA PRODUK
          const Text(
            "Nama Produk *",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            decoration: InputDecoration(
              hintText: "Masukkan nama produk",
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // HARGA + KATEGORI
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Harga *",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 50,
                          alignment:
                              Alignment.center,
                          decoration:
                              BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .grey.shade300,
                            ),
                            borderRadius:
                                const BorderRadius
                                    .only(
                              topLeft:
                                  Radius.circular(
                                      12),
                              bottomLeft:
                                  Radius.circular(
                                      12),
                            ),
                          ),
                          child:
                              const Text("Rp"),
                        ),

                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              decoration:
                                  const InputDecoration(
                                hintText:
                                    "Masukkan harga produk",
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .only(
                                    topRight:
                                        Radius.circular(
                                            12),
                                    bottomRight:
                                        Radius.circular(
                                            12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kategori *",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 50,
                      child:
                          DropdownButtonFormField<
                              String>(
                        decoration:
                            InputDecoration(
                          hintText:
                              "Pilih kategori",
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value:
                                "Makanan",
                            child: Text(
                                "Makanan"),
                          ),
                          DropdownMenuItem(
                            value:
                                "Minuman",
                            child: Text(
                                "Minuman"),
                          ),
                          DropdownMenuItem(
                            value:
                                "Elektronik",
                            child: Text(
                                "Elektronik"),
                          ),
                          DropdownMenuItem(
                            value:
                                "Fashion",
                            child:
                                Text("Fashion"),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DESKRIPSI
          const Text(
            "Deskripsi Produk",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  "Masukkan deskripsi produk",
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // FOTO PRODUK
          const Text(
            "Foto Produk *",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xff2962FF),
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 60,
                  color: Color(0xff2962FF),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Upload foto produk",
                ),

                const SizedBox(height: 8),

                const Text(
                  "PNG, JPG, JPEG (Maks. 5MB)",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.image_outlined,
                  ),
                  label: const Text(
                    "Pilih Gambar",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // BUTTON
          Row(
            children: [
              SizedBox(
                width: 150,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                  label: const Text("Batal"),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Simpan Produk",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}}