import 'package:flutter_base_app/features/auth/domain/domain.dart';

class UserLoginMapper {
  static UserLoginDto userJsonToEntity(Map<String, dynamic> json) =>
      UserLoginDto(
        id: json['id'],
        givenName: json['given_name'],
        username: json['username'],
        token: json['access_token'],
        refreshToken: json['refresh_token'],
      );
}
