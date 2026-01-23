class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  String? _token;

  String? get token => _token;
  set token(String? t) => _token = t;

  void clear() => _token = null;
}
