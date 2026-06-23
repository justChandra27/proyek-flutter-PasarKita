import 'package:flutter/material.dart';

class UsersMobilePage extends StatelessWidget {
  const UsersMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'User',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Halaman user akan segera tersedia.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
