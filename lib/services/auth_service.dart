import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlocker/config/api_routes.dart';

enum UserRole { owner, buyer }

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null;
  bool get hasRefreshToken =>
      _refreshToken != null && _refreshToken!.isNotEmpty;

  Future<void> initialise() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_PrefsKeys.accessToken);
    _refreshToken = prefs.getString(_PrefsKeys.refreshToken);
  }

  Future<void> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse(ApiRoutes.usersLogin),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw AuthException(_extractErrorMessage(res.body) ?? 'Failed to login.');
    }

    final payload = jsonDecode(res.body) as Map<String, dynamic>;
    final access = payload['access'] as String?;
    final refresh = payload['refresh'] as String?;
    if (access == null || refresh == null) {
      throw const AuthException('Invalid credentials response from server.');
    }
    await setTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final res = await http.post(
      Uri.parse(ApiRoutes.usersRegister),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role == UserRole.owner ? 'OWNER' : 'BUYER',
      }),
    );

    if (res.statusCode != 201) {
      throw AuthException(
          _extractErrorMessage(res.body) ?? 'Failed to register.');
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_PrefsKeys.accessToken);
    await prefs.remove(_PrefsKeys.refreshToken);
  }

  Future<void> setTokens({String? accessToken, String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      _accessToken = accessToken;
      await prefs.setString(_PrefsKeys.accessToken, accessToken);
    }
    if (refreshToken != null) {
      _refreshToken = refreshToken;
      await prefs.setString(_PrefsKeys.refreshToken, refreshToken);
    }
  }

  Future<bool> refresh() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final res = await http.post(
      Uri.parse(ApiRoutes.usersRefresh),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (res.statusCode != 200) {
      return false;
    }

    final payload = jsonDecode(res.body) as Map<String, dynamic>;
    final newAccess = payload['access'] as String?;
    if (newAccess == null || newAccess.isEmpty) {
      return false;
    }

    await setTokens(accessToken: newAccess);
    return true;
  }

  String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] != null)
        return decoded['detail'].toString();
      if (decoded is Map && decoded['error'] != null)
        return decoded['error'].toString();
      return decoded.toString();
    } catch (_) {
      return null;
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class _PrefsKeys {
  static const accessToken = 'accessToken';
  static const refreshToken = 'refreshToken';
}
