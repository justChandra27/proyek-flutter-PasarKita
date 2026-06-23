import 'package:flutter/material.dart';

class SettingsMobilePage extends StatelessWidget {
  const SettingsMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Halaman pengaturan akan segera tersedia.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
