/// Centralized API endpoints and base URL for the app.
class Endpoints {
  // Change this value once for all requests. Use emulator loopback for Android emulator.
  static const String baseUrl =
      'https://repository-moses-tears-browsing.trycloudflare.com/api';

  // Auth
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';

  // Users
  static const String usersMe = '/users/me';
  static const String users = '/users';

  // Admin
  static const String adminBase = '/admin';
  static const String adminCreate = '/admin/create';
  static const String adminByUsername = '/admin/{username}';
  static const String adminListPublic = '/admin/admins';

  // Incidents
  static const String incidentList = '/incidents';
  static const String incidentReport = '/incidents/report';
  static const String incidentStats = '/incidents/stats';
  static const String incidentById = '/incidents/{id}';
  static const String incidentEvidence = '/incidents/{id}/evidence';

  // Stations
  static const String stationList = '/stations';
  static const String stationById = '/stations/{id}';

  // Banners
  static const String banners = '/banners';
  static const String bannerById = '/banners/{id}';

  // Legal Documents
  static const String legalDocuments = '/legal-documents';
  static const String legalDocumentById = '/legal-documents/{id}';
  static const String legalDocumentUpload = '/legal-documents/upload';
}
