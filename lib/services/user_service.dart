import 'dart:convert';

import 'package:smartlocker/config/api_routes.dart';
import 'package:smartlocker/models/user_profile.dart';
import 'package:smartlocker/services/api_client.dart';

class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<UserProfile> fetchProfile() async {
    final response = await _apiClient.get(ApiRoutes.usersProfile);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }
}
