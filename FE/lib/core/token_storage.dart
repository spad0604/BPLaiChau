class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  String? token;
  String? username;
  String? role;

  void clear() {
    token = null;
    username = null;
    role = null;
  }
}
