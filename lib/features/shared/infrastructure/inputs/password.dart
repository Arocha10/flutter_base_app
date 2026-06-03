import 'package:formz/formz.dart';

enum PasswordError { empty, length, format }

class Password extends FormzInput<String, PasswordError> {
  static final RegExp passwordRegExp = RegExp(
    r'(?:(?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$',
  );

  const Password.pure() : super.pure('');
  const Password.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == PasswordError.empty) return 'La contraseña es requerida';
    if (displayError == PasswordError.length) return 'Mínimo 6 caracteres';
    if (displayError == PasswordError.format) return 'Debe incluir al menos una mayúscula, una minúscula y un número';
    return null;
  }

  @override
  PasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return PasswordError.empty;
    if (value.length < 6) return PasswordError.length;
    if (!passwordRegExp.hasMatch(value)) return PasswordError.format;
    return null;
  }
}
