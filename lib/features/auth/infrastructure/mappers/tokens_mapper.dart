import 'package:flutter_base_app/features/auth/domain/dtos/tokens.dto.dart';

class TokensMapper {
  static TokensDto tokensJsonToEntity(Map<String, dynamic> json) => TokensDto(
        accessToken: json['access_token'],
        refreshToken: json['refresh_token'],
      );
}
