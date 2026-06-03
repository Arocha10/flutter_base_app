import 'package:flutter_base_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_base_app/features/auth/infrastructure/errors/auth_error.dart';
import 'package:flutter_base_app/features/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:logger/logger.dart';

enum SignupFieldToFocus {
  none,
  name,
  lastName,
  username,
  email,
  password,
  confirmPassword,
}

var logger = Logger();

class SignupFormState {
  final GivenName givenName;
  final FamilyName familyName;
  final Username username;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final DateOfBirth selectedDate;
  final Gender selectedGender;
  final TermsAndConditions acceptTerms1;
  final Policies acceptTerms2;
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool passwordVisible1;
  final bool passwordVisible2;
  final bool isMainButtonPressed;
  final bool isGoogleButtonPressed;
  final bool isAppleButtonPressed;
  final String validationError;
  final SignupFieldToFocus fieldToFocus;
  final bool isEmailAlreadyInUse;

  SignupFormState({
    this.givenName = const GivenName.pure(),
    this.familyName = const FamilyName.pure(),
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.selectedDate = const DateOfBirth.pure(),
    this.selectedGender = const Gender.pure(),
    this.acceptTerms1 = const TermsAndConditions.pure(),
    this.acceptTerms2 = const Policies.pure(),
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.passwordVisible1 = false,
    this.passwordVisible2 = false,
    this.isMainButtonPressed = false,
    this.isGoogleButtonPressed = false,
    this.isAppleButtonPressed = false,
    this.fieldToFocus = SignupFieldToFocus.none,
    this.isEmailAlreadyInUse = false,
    this.validationError = '',
  });

  SignupFormState copyWith({
    GivenName? givenName,
    FamilyName? familyName,
    Username? username,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
    DateOfBirth? selectedDate,
    Gender? selectedGender,
    TermsAndConditions? acceptTerms1,
    Policies? acceptTerms2,
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? passwordVisible1,
    bool? passwordVisible2,
    bool? isMainButtonPressed,
    bool? isGoogleButtonPressed,
    bool? isAppleButtonPressed,
    SignupFieldToFocus? fieldToFocus,
    bool? isEmailAlreadyInUse,
    String? validationError,
  }) =>
      SignupFormState(
        givenName: givenName ?? this.givenName,
        familyName: familyName ?? this.familyName,
        username: username ?? this.username,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        selectedDate: selectedDate ?? this.selectedDate,
        selectedGender: selectedGender ?? this.selectedGender,
        acceptTerms1: acceptTerms1 ?? this.acceptTerms1,
        acceptTerms2: acceptTerms2 ?? this.acceptTerms2,
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        passwordVisible1: passwordVisible1 ?? this.passwordVisible1,
        passwordVisible2: passwordVisible2 ?? this.passwordVisible2,
        isMainButtonPressed: isMainButtonPressed ?? this.isMainButtonPressed,
        isGoogleButtonPressed:
            isGoogleButtonPressed ?? this.isGoogleButtonPressed,
        isAppleButtonPressed: isAppleButtonPressed ?? this.isAppleButtonPressed,
        fieldToFocus: fieldToFocus ?? this.fieldToFocus,
        isEmailAlreadyInUse: isEmailAlreadyInUse ?? this.isEmailAlreadyInUse,
        validationError: validationError ?? this.validationError,
      );
}

class SignupNotifier extends StateNotifier<SignupFormState> {
  final Function(String, String, String, String, String, String, String)
      signupUserCallback;
  final Function() signinWithGoogleCallback;
  final Function() signinWithAppleCallback;

  SignupNotifier({
    required this.signupUserCallback,
    required this.signinWithGoogleCallback,
    required this.signinWithAppleCallback,
  }) : super(SignupFormState());

  void clearFocus() {
    state = state.copyWith(fieldToFocus: SignupFieldToFocus.none);
  }

  onNameChange(String value) {
    state = state.copyWith(
        givenName: GivenName.dirty(value), isValid: _validateForm());
  }

  onLastNameChange(String value) {
    state = state.copyWith(
        familyName: FamilyName.dirty(value), isValid: _validateForm());
  }

  onUsernameChange(String value) {
    state = state.copyWith(
        username: Username.dirty(value), isValid: _validateForm());
  }

  onEmailChange(String value) {
    state = state.copyWith(isEmailAlreadyInUse: false);
    state = state.copyWith(
      email: Email.dirty(value, isAlreadyInUse: false),
      isValid: _validateForm(),
    );
  }

  onPasswordChange(String value) {
    state = state.copyWith(
        password: Password.dirty(value), isValid: _validateForm());
  }

  onConfirmPasswordChange(String value) {
    state = state.copyWith(
      confirmPassword:
          ConfirmPassword.dirty(value, password: state.password.value),
      isValid: _validateForm(),
    );
  }

  onSelectedDateChange(String value) {
    state = state.copyWith(
        selectedDate: DateOfBirth.dirty(value), isValid: _validateForm());
  }

  onSelectedGenderChange(String value) {
    state = state.copyWith(
        selectedGender: Gender.dirty(value), isValid: _validateForm());
  }

  onTerms1Change(bool value) {
    state = state.copyWith(
        acceptTerms1: TermsAndConditions.dirty(value), isValid: _validateForm());
  }

  onTerms2Change(bool value) {
    state = state.copyWith(
        acceptTerms2: Policies.dirty(value), isValid: _validateForm());
  }

  onPasswordVisibilityChange1(bool value) {
    state = state.copyWith(passwordVisible1: value);
  }

  onPasswordVisibilityChange2(bool value) {
    state = state.copyWith(passwordVisible2: value);
  }

  onMainButtonChange() {
    state = state.copyWith(isMainButtonPressed: !state.isMainButtonPressed);
  }

  onGoogleButtonChange() async {
    state = state.copyWith(isGoogleButtonPressed: !state.isGoogleButtonPressed);
    if (state.isGoogleButtonPressed) await signinWithGoogleCallback();
    state = state.copyWith(isGoogleButtonPressed: !state.isGoogleButtonPressed);
  }

  onAppleButtonChange() async {
    state = state.copyWith(isAppleButtonPressed: !state.isAppleButtonPressed);
    if (state.isAppleButtonPressed) await signinWithAppleCallback();
    state = state.copyWith(isAppleButtonPressed: !state.isAppleButtonPressed);
  }

  Future<void> onMainButtonPress() async {
    if (state.isPosting) return;
    state = state.copyWith(isMainButtonPressed: true);
    await Future.delayed(const Duration(milliseconds: 250));
    await onFormSubmit();
  }

  Future<void> onFormSubmit() async {
    _touchEveryField();

    final validationMessage = _validateFormAndGetMessage();

    if (validationMessage != null) {
      state = state.copyWith(
        validationError: validationMessage,
        isMainButtonPressed: false,
      );
      state = state.copyWith(validationError: '');

      if (!state.givenName.isValid) {
        state = state.copyWith(fieldToFocus: SignupFieldToFocus.name);
        return;
      }
      if (!state.familyName.isValid) {
        state = state.copyWith(fieldToFocus: SignupFieldToFocus.lastName);
        return;
      }
      if (!state.username.isValid) {
        state = state.copyWith(fieldToFocus: SignupFieldToFocus.username);
        return;
      }
      if (!state.email.isValid) {
        state = state.copyWith(fieldToFocus: SignupFieldToFocus.email);
        return;
      }
      if (!state.password.isValid) {
        state = state.copyWith(fieldToFocus: SignupFieldToFocus.password);
        return;
      }
      if (!state.confirmPassword.isValid) {
        state =
            state.copyWith(fieldToFocus: SignupFieldToFocus.confirmPassword);
        return;
      }
      return;
    }

    state = state.copyWith(isPosting: true);

    try {
      await signupUserCallback(
        state.givenName.value,
        state.familyName.value,
        state.username.value,
        state.email.value,
        state.password.value,
        state.selectedDate.value,
        state.selectedGender.value,
      );
      state = state.copyWith(isPosting: false, isMainButtonPressed: false);
    } on CustomError catch (e) {
      if (e.message.contains('correo ya se encuentra registrado')) {
        state = state.copyWith(
          isPosting: false,
          isMainButtonPressed: false,
          isEmailAlreadyInUse: true,
          fieldToFocus: SignupFieldToFocus.email,
        );
        state = state.copyWith(
            email: Email.dirty(state.email.value,
                isAlreadyInUse: state.isEmailAlreadyInUse));
      } else if (e.message.contains('nombre de usuario ya se encuentra en uso')) {
        state = state.copyWith(
          isPosting: false,
          isMainButtonPressed: false,
          fieldToFocus: SignupFieldToFocus.username,
        );
      } else {
        state = state.copyWith(isPosting: false, isMainButtonPressed: false);
      }
    } catch (e) {
      logger.e('onFormSubmit error: $e');
      state = state.copyWith(isPosting: false, isMainButtonPressed: false);
    }
  }

  bool _validateForm() {
    return Formz.validate([
      state.givenName,
      state.familyName,
      state.username,
      state.email,
      state.password,
      state.confirmPassword,
      state.selectedDate,
      state.selectedGender,
      state.acceptTerms1,
      state.acceptTerms2,
    ]);
  }

  String? _validateFormAndGetMessage() {
    final Map<FormzInput, String> fieldMessages = {
      state.givenName: 'ingresar tu nombre',
      state.familyName: 'ingresar tu apellido',
      state.username: 'ingresar tu nombre de usuario',
      state.email: 'ingresar tu correo electrónico',
      state.password: 'ingresar tu contraseña',
      state.confirmPassword: 'confirmar tu contraseña',
      state.selectedDate: 'seleccionar tu fecha de nacimiento',
      state.selectedGender: 'seleccionar tu género',
      state.acceptTerms1: 'aceptar los términos y condiciones',
      state.acceptTerms2: 'aceptar la política de privacidad',
    };

    final invalidFields =
        fieldMessages.entries.where((entry) => !entry.key.isValid).toList();

    if (invalidFields.isEmpty) return null;

    final bool areOnlyCheckboxesInvalid = invalidFields.length == 2 &&
        invalidFields.every((field) =>
            field.key == state.acceptTerms1 || field.key == state.acceptTerms2);

    if (areOnlyCheckboxesInvalid) {
      return 'Debes aceptar los términos y la política de privacidad';
    }

    if (invalidFields.length == 1) {
      return 'Debes ${invalidFields.first.value}';
    }

    return 'Debes completar los campos faltantes';
  }

  _touchEveryField() {
    final givenName = GivenName.dirty(state.givenName.value);
    final familyName = FamilyName.dirty(state.familyName.value);
    final username = Username.dirty(state.username.value);
    final email = Email.dirty(state.email.value,
        isAlreadyInUse: state.isEmailAlreadyInUse);
    final password = Password.dirty(state.password.value);
    final confirmPassword = ConfirmPassword.dirty(state.confirmPassword.value,
        password: state.password.value);
    final selectedDate = DateOfBirth.dirty(state.selectedDate.value);
    final selectedGender = Gender.dirty(state.selectedGender.value);
    final acceptTerms1 = TermsAndConditions.dirty(state.acceptTerms1.value);
    final acceptTerms2 = Policies.dirty(state.acceptTerms2.value);

    state = state.copyWith(
      isFormPosted: true,
      givenName: givenName,
      familyName: familyName,
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      selectedDate: selectedDate,
      selectedGender: selectedGender,
      acceptTerms1: acceptTerms1,
      acceptTerms2: acceptTerms2,
      isValid: Formz.validate([
        givenName,
        familyName,
        username,
        email,
        password,
        confirmPassword,
        selectedDate,
        selectedGender,
        acceptTerms1,
        acceptTerms2,
      ]),
    );
  }
}

final signupFormProvider =
    StateNotifierProvider.autoDispose<SignupNotifier, SignupFormState>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return SignupNotifier(
    signinWithAppleCallback: authNotifier.signInWithApple,
    signinWithGoogleCallback: authNotifier.signInWithGoogle,
    signupUserCallback: authNotifier.registerUser,
  );
});
