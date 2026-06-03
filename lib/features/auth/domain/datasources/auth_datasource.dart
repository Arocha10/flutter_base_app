import 'package:flutter_base_app/features/auth/domain/domain.dart';
import '../dtos/tokens.dto.dart';

abstract class AuthDataSource {
  Future<UserLoginDto> login(String email, String password);

  Future<UserLoginDto> register(
      String provider,
      String givenName,
      String familyName,
      String username,
      String email,
      String password,
      String dateOfBirth,
      String gender);

  Future<TokensDto> checkAuthStatus(String refreshToken);

  Future<UserLoginDto> googleSignInAuth(
      String provider,
      String givenName,
      String familyName,
      String email,
      String photo,
      bool isNew);

  Future<UserLoginDto> appleSignInAuth(
      String provider,
      String givenName,
      String familyName,
      String email,
      String photo,
      bool isNew);

  Future<void> setRecoveryCode(String email);

  Future<UserLoginDto> verifyRecoveryCode(String email, int code);

  Future<void> updatePassword(String newPassword, String accessToken);
}
