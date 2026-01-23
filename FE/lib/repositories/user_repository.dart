import '../services/api_service.dart';
import '../core/token_storage.dart';
import '../models/user_model.dart';
import '../core/endpoints.dart';

class UserRepository {
  final ApiService api;
  UserRepository(this.api);

  /// Attempts login; stores token on success and returns a UserModel.
  Future<UserModel> login(String username, String password) async {
    final res = await api.post(Endpoints.AUTH_LOGIN, {
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
    if (userJson is Map<String, dynamic>) {
      return UserModel.fromJson(userJson);
    }

    return UserModel(username: username, role: '');
  }

  Future<UserModel> profile() async {
    final res = await api.get(Endpoints.USERS_ME);
    final payload = (res is Map && res['data'] != null) ? res['data'] : res;
    final userJson = payload is Map ? payload : {};
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }
}
