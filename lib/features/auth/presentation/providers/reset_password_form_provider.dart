import 'package:flutter_base_app/features/shared/infrastructure/inputs/password.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newPasswordFormProvider =
    StateNotifierProvider<NewPasswordFormNotifier, NewPasswordFormState>(
        (ref) => NewPasswordFormNotifier());

class NewPasswordFormState {
  final Password newPassword;
  final Password confirmNewPassword;
  final bool isFormPosted;
  final bool passwordVisible1;
  final bool passwordVisible2;

  NewPasswordFormState({
    this.newPassword = const Password.pure(),
    this.confirmNewPassword = const Password.pure(),
    this.isFormPosted = false,
    this.passwordVisible1 = false,
    this.passwordVisible2 = false,
  });

  NewPasswordFormState copyWith({
    Password? newPassword,
    Password? confirmNewPassword,
    bool? isFormPosted,
    bool? passwordVisible1,
    bool? passwordVisible2,
  }) =>
      NewPasswordFormState(
        newPassword: newPassword ?? this.newPassword,
        confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        passwordVisible1: passwordVisible1 ?? this.passwordVisible1,
        passwordVisible2: passwordVisible2 ?? this.passwordVisible2,
      );
}

class NewPasswordFormNotifier extends StateNotifier<NewPasswordFormState> {
  NewPasswordFormNotifier() : super(NewPasswordFormState());

  void onNewPasswordChange(String value) {
    state = state.copyWith(
      newPassword: Password.dirty(value),
      isFormPosted: false,
    );
  }

  void onConfirmNewPasswordChange(String value) {
    state = state.copyWith(
      confirmNewPassword: Password.dirty(value),
      isFormPosted: false,
    );
  }

  void onPasswordVisibilityChange1(bool value) {
    state = state.copyWith(passwordVisible1: value);
  }

  void onPasswordVisibilityChange2(bool value) {
    state = state.copyWith(passwordVisible2: value);
  }

  void onFormSubmit() {
    _validateForm();
    state = state.copyWith(isFormPosted: true);
  }

  void _validateForm() {
    state = state.copyWith(
      newPassword: Password.dirty(state.newPassword.value),
      confirmNewPassword: Password.dirty(state.confirmNewPassword.value),
    );
  }
}
