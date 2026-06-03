import 'package:flutter_base_app/config/const/environment.dart';
import 'package:flutter_base_app/features/auth/domain/domain.dart';
import 'package:flutter_base_app/features/auth/infrastructure/errors/auth_error.dart';
import 'package:flutter_base_app/features/auth/infrastructure/mappers/user_login_mapper.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../domain/dtos/tokens.dto.dart';
import '../mappers/tokens_mapper.dart';

class AuthDataSourceImpl extends AuthDataSource {
  var logger = Logger();

  final dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    connectTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(seconds: 25),
  ));

  @override
  Future<TokensDto> checkAuthStatus(String refreshToken) async {
    logger.d('AuthDataSourceImpl checkAuthStatus');

    try {
      final response = await dio.post('/auth/refresh-token',
          options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'}));

      return TokensMapper.tokensJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw CustomError('Token incorrecto, debes iniciar sesión nuevamente');
      }
      logger.e('checkAuthStatus error: $e');
      throw Exception();
    } catch (e) {
      logger.e('checkAuthStatus error: $e');
      throw Exception();
    }
  }

  @override
  Future<UserLoginDto> login(String email, String password) async {
    logger.d('AuthDataSourceImpl login');

    try {
      final response = await dio
          .post('/auth/login', data: {'query': email, 'password': password});

      return UserLoginMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw CustomError(
            e.response?.data['message'] ?? 'Revisa los datos ingresados');
      }
      if (e.response?.statusCode == 401) {
        throw CustomError(
            e.response?.data['message'] ?? 'Credenciales incorrectas');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception(e);
    } catch (e) {
      logger.e('login error: $e');
      throw Exception(e);
    }
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
      String gender) async {
    String normalizedGender = _normalizeGender(gender);

    logger.d('AuthDataSourceImpl register');

    try {
      final response = await dio.post('/auth', data: {
        'provider': provider,
        'given_name': givenName,
        'family_name': familyName,
        'username': username,
        'email': email,
        'password': password,
        'date_of_birth': dateOfBirth,
        'gender': normalizedGender,
      });

      return UserLoginMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '';
        if (message.contains('email')) {
          throw CustomError('El correo ya se encuentra registrado');
        }
        if (message.contains('username')) {
          throw CustomError('El nombre de usuario ya se encuentra en uso');
        }
        throw CustomError(message.isNotEmpty ? message : 'Revisa los datos ingresados');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      logger.e('register error: $e');
      throw Exception(e);
    } catch (e) {
      logger.e('register error: $e');
      throw Exception(e);
    }
  }

  @override
  Future<UserLoginDto> googleSignInAuth(String provider, String givenName,
      String familyName, String email, String photo, bool isNew) async {
    logger.d('AuthDataSourceImpl googleSignInAuth');

    try {
      final response = await dio.post('/auth/google-signin', data: {
        'provider': provider,
        'given_name': givenName,
        'family_name': familyName,
        'email': email,
        'photo': photo,
        'is_new': isNew,
      });

      return UserLoginMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '';
        if (message.contains('email')) {
          throw CustomError('El correo ya se encuentra registrado');
        }
        throw CustomError(message.isNotEmpty ? message : 'Revisa los datos ingresados');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      logger.e('googleSignInAuth error: $e');
      throw Exception(e);
    } catch (e) {
      logger.e('googleSignInAuth error: $e');
      throw Exception(e);
    }
  }

  @override
  Future<UserLoginDto> appleSignInAuth(String provider, String givenName,
      String familyName, String email, String photo, bool isNew) async {
    logger.d('AuthDataSourceImpl appleSignInAuth');

    try {
      final response = await dio.post('/auth/apple-signin', data: {
        'provider': provider,
        'email': email,
        'is_new': isNew,
      });

      return UserLoginMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '';
        throw CustomError(message.isNotEmpty ? message : 'Revisa los datos ingresados');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      logger.e('appleSignInAuth error: $e');
      throw Exception(e);
    } catch (e) {
      logger.e('appleSignInAuth error: $e');
      throw Exception(e);
    }
  }

  @override
  Future<void> setRecoveryCode(String email) async {
    logger.d('AuthDataSourceImpl setRecoveryCode');

    try {
      await dio.post('/auth/set-recovery-code', data: {'email': email});
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception(e);
    } catch (e) {
      logger.e('setRecoveryCode error: $e');
      throw Exception(e);
    }
  }

  @override
  Future<UserLoginDto> verifyRecoveryCode(String email, int code) async {
    logger.d('AuthDataSourceImpl verifyRecoveryCode');

    try {
      final response = await dio
          .post('/auth/verifyCode', data: {'email': email, 'code': code});

      return UserLoginMapper.userJsonToEntity(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception(e);
    } catch (e) {
      logger.e('verifyRecoveryCode error: $e');
      throw Exception(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword, String accessToken) async {
    logger.d('AuthDataSourceImpl updatePassword');

    try {
      await dio.patch(
        '/auth/update-password',
        data: {'password': newPassword},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception(e);
    } catch (e) {
      logger.e('updatePassword error: $e');
      throw Exception(e);
    }
  }

  String _normalizeGender(String gender) {
    switch (gender) {
      case 'Masculino':
        return 'male';
      case 'Femenino':
        return 'female';
      case 'Otro':
        return 'other';
      case 'Prefiero no decirlo':
        return 'unspecified';
      default:
        return gender.toLowerCase();
    }
  }
}
