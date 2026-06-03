import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/domain/dtos/tokens.dto.dart';
import '../../auth/infrastructure/datasources/auth_datasource_impl.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  final Logger logger = Logger();
  final Dio _refreshDio = Dio();

  AuthInterceptor(this.ref);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      logger.d('AuthInterceptor: Adding token to request: ${options.uri}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      logger.d('AuthInterceptor: Token expired, attempting refresh');

      try {
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString('refreshToken');

        if (refreshToken == null) {
          logger.e('AuthInterceptor: No refresh token available');
          return handler.next(err);
        }

        final authDataSource = AuthDataSourceImpl();
        final TokensDto tokens =
            await authDataSource.checkAuthStatus(refreshToken);

        await prefs.setString('token', tokens.accessToken);
        await prefs.setString('refreshToken', tokens.refreshToken);

        logger.d('AuthInterceptor: Token refreshed successfully');

        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';

        final response = await _refreshDio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        logger.e('AuthInterceptor: Failed to refresh token: $e');
      }
    }

    return handler.next(err);
  }
}
