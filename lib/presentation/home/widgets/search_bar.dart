import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {

  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: TextField(

        decoration: InputDecoration(

          hintText: "Cari produk...",

          prefixIcon: const Icon(Icons.search),

          filled: true,

          fillColor: const Color(0xFF1A1A1A),

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(16),

            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}