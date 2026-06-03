import 'package:formz/formz.dart';

enum UsernameError { empty, invalid, tooShort, tooLong }

class Username extends FormzInput<String, UsernameError> {
  static final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9._-]+$');
  static const int minLength = 6;
  static const int maxLength = 20;

  const Username.pure() : super.pure('');
  const Username.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == UsernameError.empty) return 'El nombre de usuario es requerido';
    if (displayError == UsernameError.invalid) return 'Solo letras, números, puntos, guiones bajos y guiones';
    if (displayError == UsernameError.tooShort) return 'Mínimo $minLength caracteres';
    if (displayError == UsernameError.tooLong) return 'Máximo $maxLength caracteres';
    return null;
  }

  @override
  UsernameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return UsernameError.empty;
    if (!usernameRegExp.hasMatch(value)) return UsernameError.invalid;
    if (value.length < minLength) return UsernameError.tooShort;
    if (value.length > maxLength) return UsernameError.tooLong;
    return null;
  }
}
