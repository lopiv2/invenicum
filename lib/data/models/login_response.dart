import 'package:invenicum/data/models/user_data_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final UserData? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Extraer los datos del objeto 'data' si existe
    final Map<String, dynamic> data = json['data'] is Map ? json['data'] : json;

    final response = LoginResponse(
      success: data['success'] ?? false,
      message: data['message']?.toString() ?? '',
      token: data['token']?.toString(),
      user: data['user'] != null ? UserData.fromJson(data['user']) : null,
    );

    return response;
  }
}


