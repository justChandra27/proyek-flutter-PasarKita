import 'package:flutter/material.dart';

class SellerTipCard extends StatelessWidget {
  const SellerTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffFDE68A).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: Color(0xffD97706),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Penjualan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xff92400E),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gunakan foto berkualitas tinggi dan deskripsi yang jelas '
                  'untuk menarik lebih banyak pembeli. Pastikan harga kompetitif '
                  'dengan produk serupa.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xffA16207),
                    height: 1.4,
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
