import 'endpoints.dart';

/// Helper class to convert relative URLs to absolute URLs
class UrlHelper {
  /// Convert a relative URL to an absolute URL by prepending the base URL
  /// Also replaces any localhost URLs from backend with the actual base URL
  static String toAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) {
      return '';
    }

    // Already an absolute URL from backend? Replace localhost if needed
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Replace localhost:8000 with actual base URL
      if (url.contains('localhost:8000') || url.contains('127.0.0.1:8000')) {
        // Extract just the path part
        final uri = Uri.parse(url);
        final path = uri.path; // e.g., /static/uploads/...

        // Get base URL without /api
        final baseWithoutApi = Endpoints.baseUrl.replaceAll('/api', '');
        return '$baseWithoutApi$path';
      }
      return url;
    }

    // Relative URL - prepend base URL
    final baseUrl = Endpoints.baseUrl.replaceAll('/api', '');

    // Ensure no double slashes
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    } else {
      return '$baseUrl/$url';
    }
  }

  /// Convert a list of URLs to absolute URLs
  static List<String> toAbsoluteUrls(List<String>? urls) {
    if (urls == null || urls.isEmpty) return [];
    return urls.map((url) => toAbsoluteUrl(url)).toList();
  }
}
