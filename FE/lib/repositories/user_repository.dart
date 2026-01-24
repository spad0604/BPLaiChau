import '../services/api_service.dart';
import '../core/token_storage.dart';
import '../models/user_model.dart';
import '../core/endpoints.dart';

class UserRepository {
  final ApiService api;
  UserRepository(this.api);

  /// Attempts login; stores token on success and returns a UserModel.
  Future<UserModel> login(String username, String password) async {
    // BE uses OAuth2PasswordRequestForm, so send x-www-form-urlencoded.
    final res = await api.postFormUrlEncoded(Endpoints.authLogin, {
      'username': username,
      'password': password,
    });

    // Expecting backend to return BaseResponse { status, message, data }
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;

    final token =
        payload['access_token'] ??
        payload['token'] ??
        res['access_token'] ??
        res['token'];
    if (token != null) TokenStorage.instance.token = token.toString();

    final userJson = payload['user'] ?? payload;
    UserModel user;
    if (userJson is Map) {
      user = UserModel.fromJson(Map<String, dynamic>.from(userJson));
    } else {
      user = UserModel(username: username, role: '');
    }

    // Persist for role-gated UI.
    TokenStorage.instance.username = user.username.isNotEmpty ? user.username : username;
    TokenStorage.instance.role = user.role;
    return user;
  }

  Future<UserModel> profile() async {
    final res = await api.get(Endpoints.usersMe);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final userJson = payload is Map ? payload : {};
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }
}
