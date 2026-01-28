import 'endpoints.dart';

/// Helper class to handle URL transformations for files and images
class UrlHelper {
  /// Convert a relative or absolute file URL to an absolute URL with base URL
  /// If the URL is already absolute (starts with http/https), return as-is
  /// Otherwise, prepend the base URL (without /api suffix)
  static String toAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Already absolute
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Get base URL without /api suffix
    final baseUrl = Endpoints.baseUrl.replaceAll('/api', '');

    // Ensure URL starts with /
    final cleanUrl = url.startsWith('/') ? url : '/$url';

    return '$baseUrl$cleanUrl';
  }

  /// Convert a list of URLs to absolute URLs
  static List<String> toAbsoluteUrls(List<String>? urls) {
    if (urls == null || urls.isEmpty) return [];
    return urls.map((url) => toAbsoluteUrl(url)).toList();
  }
}
