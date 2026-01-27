import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<void> saveBytes({
  required String filename,
  required List<int> bytes,
  String mimeType = 'application/octet-stream',
}) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save file',
    fileName: filename,
    type: FileType.custom,
    allowedExtensions: const ['csv'],
  );

  if (path == null || path.trim().isEmpty) return;

  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
}
