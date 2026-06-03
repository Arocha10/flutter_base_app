import 'package:formz/formz.dart';

enum GivenNameError { empty, invalid }

class GivenName extends FormzInput<String, GivenNameError> {
  const GivenName.pure() : super.pure('');
  const GivenName.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == GivenNameError.empty) return 'El nombre es requerido';
    if (displayError == GivenNameError.invalid) return 'El nombre solo debe contener letras y espacios';
    return null;
  }

  @override
  GivenNameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return GivenNameError.empty;
    if (!_isValidName(value)) return GivenNameError.invalid;
    return null;
  }

  bool _isValidName(String value) {
    return value.split('').every((char) =>
        char.toLowerCase().compareTo('a') >= 0 &&
            char.toLowerCase().compareTo('z') <= 0 ||
        'áéíóúüñ'.contains(char.toLowerCase()) ||
        char == ' ');
  }
}
