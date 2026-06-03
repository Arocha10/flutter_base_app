import 'package:formz/formz.dart';

enum ConfirmPasswordError { empty, noMatch }

class ConfirmPassword extends FormzInput<String, ConfirmPasswordError> {
  final String password;

  const ConfirmPassword.pure({this.password = ''}) : super.pure('');
  // ignore: use_super_parameters
  const ConfirmPassword.dirty(String value, {this.password = ''}) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == ConfirmPasswordError.empty) return 'La confirmación es requerida';
    if (displayError == ConfirmPasswordError.noMatch) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  ConfirmPasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return ConfirmPasswordError.empty;
    if (value != password) return ConfirmPasswordError.noMatch;
    return null;
  }
}
