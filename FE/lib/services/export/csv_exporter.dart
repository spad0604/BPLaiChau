import 'dart:convert';

import 'export_platform.dart' as platform;

class CsvExporter {
  static List<int> _withBom(List<int> bytes) => <int>[0xEF, 0xBB, 0xBF, ...bytes];

  static String _escape(String value) {
    final v = value;
    final needsQuote = v.contains(',') || v.contains('\n') || v.contains('\r') || v.contains('"');
    if (!needsQuote) return v;
    return '"${v.replaceAll('"', '""')}"';
  }

  static String buildCsv({required List<String> headers, required List<List<String>> rows}) {
    final buf = StringBuffer();
    buf.writeln(headers.map(_escape).join(','));
    for (final r in rows) {
      buf.writeln(r.map(_escape).join(','));
    }
    return buf.toString();
  }

  static Future<void> export({
    required String filename,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final csv = buildCsv(headers: headers, rows: rows);
    final bytes = _withBom(utf8.encode(csv));
    await platform.saveBytes(
      filename: filename,
      bytes: bytes,
      mimeType: 'text/csv;charset=utf-8',
    );
  }
}
