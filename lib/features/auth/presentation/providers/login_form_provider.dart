import 'package:flutter_base_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_base_app/features/shared/infrastructure/inputs/username_email.dart';
import 'package:flutter_base_app/features/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final UsernameOrEmail usernameOrEmail;
  final Password password;
  final bool passwordVisible;
  final bool isMainButtonPressed;
  final bool isGoogleButtonPressed;
  final bool isAppleButtonPressed;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.usernameOrEmail = const UsernameOrEmail.pure(),
    this.password = const Password.pure(),
    this.passwordVisible = false,
    this.isMainButtonPressed = false,
    this.isGoogleButtonPressed = false,
    this.isAppleButtonPressed = false,
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    UsernameOrEmail? usernameOrEmail,
    Password? password,
    bool? passwordVisible,
    bool? isMainButtonPressed,
    bool? isGoogleButtonPressed,
    bool? isAppleButtonPressed,
  }) =>
      LoginFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        usernameOrEmail: usernameOrEmail ?? this.usernameOrEmail,
        password: password ?? this.password,
        passwordVisible: passwordVisible ?? this.passwordVisible,
        isMainButtonPressed: isMainButtonPressed ?? this.isMainButtonPressed,
        isGoogleButtonPressed:
            isGoogleButtonPressed ?? this.isGoogleButtonPressed,
        isAppleButtonPressed: isAppleButtonPressed ?? this.isAppleButtonPressed,
      );
}

class LoginNotifier extends StateNotifier<LoginFormState> {
  final Function(String, String) loginUserCallback;
  final Function() signinWithGoogleCallback;
  final Function() signinWithAppleCallback;

  LoginNotifier({
    required this.loginUserCallback,
    required this.signinWithGoogleCallback,
    required this.signinWithAppleCallback,
  }) : super(LoginFormState());

  onEmailChange(String value) {
    final newUsernameOrEmail = UsernameOrEmail.dirty(value);
    state = state.copyWith(
        usernameOrEmail: newUsernameOrEmail,
        isValid: Formz.validate([newUsernameOrEmail, state.password]));
  }

  onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate([state.usernameOrEmail, newPassword]));
  }

  onPasswordVisibilityChange(bool value) {
    state = state.copyWith(passwordVisible: value);
  }

  Future<void> onMainButtonPress() async {
    if (state.isPosting) return;
    state = state.copyWith(isMainButtonPressed: true);
    await Future.delayed(const Duration(milliseconds: 250));
    await onFormSubmit();
  }

  onMainButtonChange() {
    state = state.copyWith(isMainButtonPressed: !state.isMainButtonPressed);
  }

  onGoogleButtonChange() async {
    state = state.copyWith(isGoogleButtonPressed: !state.isGoogleButtonPressed);
    if (state.isGoogleButtonPressed) {
      await signinWithGoogleCallback();
    }
    state = state.copyWith(isGoogleButtonPressed: !state.isGoogleButtonPressed);
  }

  onAppleButtonChange() async {
    state = state.copyWith(isAppleButtonPressed: !state.isAppleButtonPressed);
    if (state.isAppleButtonPressed) {
      await signinWithAppleCallback();
    }
    state = state.copyWith(isAppleButtonPressed: !state.isAppleButtonPressed);
  }

  onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) {
      state = state.copyWith(isMainButtonPressed: false);
      return;
    }

    try {
      state = state.copyWith(isPosting: true);
      await loginUserCallback(
          state.usernameOrEmail.value, state.password.value);
      state = state.copyWith(
          isPosting: false, isFormPosted: true, isMainButtonPressed: false);
    } catch (error) {
      state = state.copyWith(
          isPosting: false, isFormPosted: true, isMainButtonPressed: false);
    }
  }

  _touchEveryField() {
    final usernameOrEmail = UsernameOrEmail.dirty(state.usernameOrEmail.value);
    final password = Password.dirty(state.password.value);
    state = state.copyWith(
        isFormPosted: true,
        usernameOrEmail: usernameOrEmail,
        password: password,
        isValid: Formz.validate([usernameOrEmail, password]));
  }
}

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginFormState>((ref) {
  final loginUserCallback = ref.watch(authProvider.notifier).loginUser;
  final signinWithGoogleCallback =
      ref.watch(authProvider.notifier).signInWithGoogle;
  final signinWithAppleCallback =
      ref.watch(authProvider.notifier).signInWithApple;

  return LoginNotifier(
    signinWithAppleCallback: signinWithAppleCallback,
    signinWithGoogleCallback: signinWithGoogleCallback,
    loginUserCallback: loginUserCallback,
  );
});
