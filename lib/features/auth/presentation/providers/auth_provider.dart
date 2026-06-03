import 'package:flutter_base_app/features/auth/domain/domain.dart';
import 'package:flutter_base_app/features/auth/domain/dtos/tokens.dto.dart';
import 'package:flutter_base_app/features/auth/infrastructure/errors/auth_error.dart';
import 'package:flutter_base_app/features/auth/infrastructure/infrastructure.dart';
import 'package:flutter_base_app/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:flutter_base_app/features/shared/infrastructure/services/key_value_storage_service_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

var logger = Logger();

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final UserLoginDto? loginUserDto;
  final String errorMessage;
  final bool isAuthenticating;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.loginUserDto,
    this.errorMessage = '',
    this.isAuthenticating = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    UserLoginDto? loginUserDto,
    String? errorMessage,
    bool? isAuthenticating,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        loginUserDto: loginUserDto ?? this.loginUserDto,
        errorMessage: errorMessage ?? this.errorMessage,
        isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> _markOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', value);
  }

  Future<void> loginUser(String email, String password) async {
    state = state.copyWith(errorMessage: '', isAuthenticating: true);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final loginUserDto = await authRepository.login(email, password);
      _setLoggedUser(loginUserDto, false);
    } on CustomError catch (e) {
      logout(e.message);
      rethrow;
    } catch (e) {
      logger.e('loginUser error: $e');
      logout('Error no controlado');
      rethrow;
    }
  }

  Future<void> registerUser(
    String givenName,
    String familyName,
    String username,
    String email,
    String password,
    String dateOfBirth,
    String gender,
  ) async {
    state = state.copyWith(errorMessage: '', isAuthenticating: true);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final user = await authRepository.register(
          'email', givenName, familyName, username, email, password, dateOfBirth, gender);
      _setLoggedUser(user, false);
      _markOnboardingComplete(true);
    } on CustomError catch (e) {
      state = state.copyWith(isAuthenticating: false, errorMessage: e.message);
      // ignore: use_rethrow_when_possible
      throw e;
    } catch (e) {
      logger.e('registerUser error: $e');
      logout('Error no controlado');
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(errorMessage: '', isAuthenticating: true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isAuthenticating: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final additionalUserInfo = authResult.additionalUserInfo;

      if (additionalUserInfo != null && additionalUserInfo.profile != null) {
        final profile = additionalUserInfo.profile as Map<String, dynamic>;

        final givenName = profile['given_name'] ?? '';
        final familyName = profile['family_name'] ?? '';
        final email = profile['email'] ?? '';
        final photo = profile['picture'] ?? '';

        try {
          final loginUserDto = await authRepository.googleSignInAuth(
              'google', givenName, familyName, email, photo,
              additionalUserInfo.isNewUser);

          _setLoggedUser(loginUserDto, false);
          _markOnboardingComplete(true);
        } on CustomError catch (e) {
          logout(e.message);
        } catch (e) {
          logger.e('signInWithGoogle backend error: $e');
          firebaseLogout();
          logout('No se logró establecer conexión con el servidor');
        }
      }
    } catch (e) {
      logger.e('signInWithGoogle error: $e');
      firebaseLogout();
      logout('Error al iniciar sesión con Google');
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(errorMessage: '', isAuthenticating: true);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final additionalUserInfo = authResult.additionalUserInfo;

      if (additionalUserInfo != null && additionalUserInfo.profile != null) {
        final profile = additionalUserInfo.profile as Map<String, dynamic>;

        final givenName = profile['given_name'] ?? '';
        final familyName = profile['family_name'] ?? '';
        final email = profile['email'] ?? '';
        final photo = profile['picture'] ?? '';

        try {
          final loginUserDto = await authRepository.appleSignInAuth(
              'apple', givenName, familyName, email, photo,
              additionalUserInfo.isNewUser);

          _setLoggedUser(loginUserDto, false);
          _markOnboardingComplete(true);
        } on CustomError catch (e) {
          logout(e.message);
        } catch (e) {
          logger.e('signInWithApple backend error: $e');
          firebaseLogout();
          logout('No se logró establecer conexión con el servidor');
        }
      }
    } catch (e) {
      logger.e('signInWithApple error: $e');
      firebaseLogout();
      logout('Error al iniciar sesión con Apple');
    }
  }

  void firebaseLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      state = state.copyWith(isAuthenticating: false);
    } catch (e) {
      logger.e('firebaseLogout error: $e');
    }
  }

  void checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    state = state.copyWith(isAuthenticating: true);

    if (refreshToken == null) {
      logger.w('checkAuthStatus: no refreshToken, logging out');
      return logout();
    }

    try {
      final TokensDto tokensDto =
          await authRepository.checkAuthStatus(refreshToken);

      final userLoginDto = UserLoginDto(
        token: tokensDto.accessToken,
        refreshToken: tokensDto.refreshToken,
        id: '',
        givenName: '',
        username: '',
      );

      _setLoggedUser(userLoginDto, true);
    } catch (e) {
      logger.e('checkAuthStatus error: $e');
      logout();
      firebaseLogout();
    }
  }

  void _setLoggedUser(UserLoginDto user, bool? isFromRefreshTokens) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    await keyValueStorageService.setKeyValue('refreshToken', user.refreshToken);

    if (isFromRefreshTokens == true) {
      final refreshedUser = UserLoginDto(
        token: user.token,
        refreshToken: user.refreshToken,
        id: '',
        givenName: '',
        username: '',
      );

      state = state.copyWith(
        loginUserDto: refreshedUser,
        authStatus: AuthStatus.authenticated,
        errorMessage: '',
        isAuthenticating: false,
      );
      return;
    }

    state = state.copyWith(
      loginUserDto: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      isAuthenticating: false,
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeKey('token');
    await keyValueStorageService.removeKey('refreshToken');
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      loginUserDto: null,
      errorMessage: errorMessage,
      isAuthenticating: false,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService,
  );
});
