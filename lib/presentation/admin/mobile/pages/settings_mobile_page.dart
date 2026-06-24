import 'package:flutter/material.dart';

import '../../../../core/appwrite/appwrite_config.dart';

class SettingsMobilePage extends StatelessWidget {
  const SettingsMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          'Informasi Aplikasi',
          [
            _infoTile('Nama Aplikasi', 'PasarKita'),
            _infoTile('Database ID', AppwriteConfig.databaseId),
            _infoTile('Project ID', AppwriteConfig.projectId),
            _infoTile('Endpoint', AppwriteConfig.endpoint),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Dukungan',
          [
            ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xff2563EB)),
              title: const Text('Pusat Bantuan'),
              subtitle: const Text('Dokumentasi dan panduan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: Color(0xff2563EB)),
              title: const Text('Kirim Masukan'),
              subtitle: const Text('Laporkan masalah atau saran'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Tentang',
          [
            const ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xff2563EB)),
              title: Text('Versi'),
              subtitle: Text('1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
