import 'package:flutter/material.dart';

import '../../../../data/models/moderation_status.dart';

class ModerationStatusBadge extends StatelessWidget {
  final ModerationStatus status;

  const ModerationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case ModerationStatus.approved:
        bgColor = Colors.green.shade100;
        textColor = Colors.green;
        label = 'Disetujui';
      case ModerationStatus.pending:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange;
        label = 'Menunggu';
      case ModerationStatus.rejected:
        bgColor = Colors.red.shade100;
        textColor = Colors.red;
        label = 'Ditolak';
      case ModerationStatus.deactivated:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey;
        label = 'Nonaktif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
