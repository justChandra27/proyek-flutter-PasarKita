import 'dart:io';
import 'dart:convert';

class CsvExportService {
  static void export(String csvContent, String filename) {
    try {
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/$filename');
      file.writeAsBytesSync(utf8.encode(csvContent));
    } catch (_) {
      // Silent fallback — tidak crash
    }
  }

  static bool get isExportSupported => false;
}
