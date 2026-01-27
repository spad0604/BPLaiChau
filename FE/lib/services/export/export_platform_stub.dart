// Platform abstraction for saving bytes as a file.
//
// - Web: triggers a browser download.
// - Desktop/mobile: opens a save dialog (when available) then writes to disk.

Future<void> saveBytes({
  required String filename,
  required List<int> bytes,
  String mimeType = 'application/octet-stream',
}) {
  throw UnsupportedError('saveBytes is not supported on this platform');
}
