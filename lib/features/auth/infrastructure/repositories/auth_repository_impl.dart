import 'package:flutter_base_app/features/auth/domain/domain.dart';
import 'package:flutter_base_app/features/auth/infrastructure/infrastructure.dart';
import '../../domain/dtos/tokens.dto.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
      : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<TokensDto> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<UserLoginDto> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<UserLoginDto> register(
      String provider,
      String givenName,
      String familyName,
      String username,
      String email,
      String password,
      String dateOfBirth,
      String gender) {
    return dataSource.register(
        provider, givenName, familyName, username, email, password, dateOfBirth, gender);
  }

  @override
  Future<UserLoginDto> googleSignInAuth(String provider, String givenName,
      String familyName, String email, String photo, bool isNew) {
    return dataSource.googleSignInAuth(
        provider, givenName, familyName, email, photo, isNew);
  }

  @override
  Future<UserLoginDto> appleSignInAuth(String provider, String givenName,
      String familyName, String email, String photo, bool isNew) {
    return dataSource.appleSignInAuth(
        provider, givenName, familyName, email, photo, isNew);
  }

  @override
  Future<void> setRecoveryCode(String email) {
    return dataSource.setRecoveryCode(email);
  }

  @override
  Future<UserLoginDto> verifyRecoveryCode(String email, int code) {
    return dataSource.verifyRecoveryCode(email, code);
  }

  @override
  Future<void> updatePassword(String newPassword, String accessToken) {
    return dataSource.updatePassword(newPassword, accessToken);
  }
}
