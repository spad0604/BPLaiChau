/// Centralized API endpoints and base URL for the app.
class Endpoints {
  // Change this value once for all requests. Use emulator loopback for Android emulator.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String AUTH_LOGIN = '/auth/login';
  static const String AUTH_LOGOUT = '/auth/logout';

  // Users
  static const String USERS_ME = '/users/me';
  static const String USERS = '/users';

  // Admin
  static const String ADMIN_BASE = '/admin';
  static const String ADMIN_CREATE = '/admin/create';
  static const String ADMIN_BY_USERNAME = '/admin/{username}';
  static const String ADMIN_LIST_PUBLIC = '/admin/admins';

  // Incidents
  static const String INCIDENT_LIST = '/incidents';
  static const String INCIDENT_REPORT = '/incidents/report';
  static const String INCIDENT_BY_ID = '/incidents/{id}';
  static const String INCIDENT_EVIDENCE = '/incidents/{id}/evidence';
}
