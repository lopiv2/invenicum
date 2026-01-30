import 'package:invenicum/models/user_theme_config_model.dart';

class UserData {
  final int id;
  final String email;
  final String name;
  final UserThemeConfig? themeConfig;

  UserData({
    required this.id,
    required this.email,
    required this.name,
    this.themeConfig,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    print('Parsing User Data:');
    print('- Raw User Data: $json');

    final userData = UserData(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      themeConfig: json['themeConfig'] != null
          ? UserThemeConfig.fromJson(json['themeConfig'])
          : null,
    );

    print('- Parsed User Data:');
    print('  * ID: ${userData.id}');
    print('  * Email: ${userData.email}');
    print('  * Name: ${userData.name}');
    print('  * Theme Config: ${userData.themeConfig}');

    return userData;
  }
}
