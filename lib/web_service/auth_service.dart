import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nctu/Models/users_model.dart';


class AuthService {
  static const _baseUrl = 'https://apex.oracle.com/pls/apex/fain_app/USERS';

  Future<UserResponse> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login/');
    final res = await http.post(
      url,
      body: {"p_user_name": username.trim(), "p_password": password.trim()},
    );

    if (res.statusCode != 200) {
      throw Exception('Network error ⇢ ${res.statusCode}');
    }

    final jsonBody = jsonDecode(res.body) as Map<String, dynamic>;
    return UserResponse.fromJson(jsonBody);
  }
}
