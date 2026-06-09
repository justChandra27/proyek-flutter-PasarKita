import 'package:flutter/material.dart';

class ProductPreviewCard extends StatelessWidget {
  const ProductPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Preview Produk",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffF5F7FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 80,
                color: Color(0xff2962FF),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Divider(),

          _item("Nama Produk", "Belum diisi"),
          _item("Harga", "Rp 0"),
          _item("Kategori", "Belum dipilih"),
          _item("Deskripsi", "Belum diisi"),
        ],
      ),
    );
  }

  Widget _item(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}