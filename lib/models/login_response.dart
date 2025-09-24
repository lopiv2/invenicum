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

class UserData {
  final int id;
  final String email;
  final String name;

  UserData({required this.id, required this.email, required this.name});

  factory UserData.fromJson(Map<String, dynamic> json) {
    print('Parsing User Data:');
    print('- Raw User Data: $json');

    final userData = UserData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );

    print('- Parsed User Data:');
    print('  * ID: ${userData.id}');
    print('  * Email: ${userData.email}');
    print('  * Name: ${userData.name}');

    return userData;
  }
}
