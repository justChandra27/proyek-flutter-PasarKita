import 'dart:html' show Blob, Url, AnchorElement;

class CsvExportService {
  static void export(String csvContent, String filename) {
    final blob = Blob([csvContent], 'text/csv');
    final url = Url.createObjectUrlFromBlob(blob);

    AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    Url.revokeObjectUrl(url);
  }

  static bool get isExportSupported => true;
}
