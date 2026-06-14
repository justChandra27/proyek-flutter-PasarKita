import 'package:flutter/material.dart';

Future<String?> showModerationDialog(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required Color actionColor,
}) {
  final noteController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: noteController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Alasan moderasi',
          hintText: 'Masukkan alasan...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: actionColor),
          onPressed: () {
            final note = noteController.text.trim();
            if (note.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alasan moderasi wajib diisi')),
              );
              return;
            }
            Navigator.pop(ctx, note);
          },
          child: Text(
            actionLabel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
