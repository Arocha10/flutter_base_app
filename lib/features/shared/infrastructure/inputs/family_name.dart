import 'package:formz/formz.dart';

enum FamilyNameError { empty, invalid }

class FamilyName extends FormzInput<String, FamilyNameError> {
  const FamilyName.pure() : super.pure('');
  const FamilyName.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == FamilyNameError.empty) return 'El apellido es requerido';
    if (displayError == FamilyNameError.invalid) return 'El apellido solo debe contener letras y espacios';
    return null;
  }

  @override
  FamilyNameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return FamilyNameError.empty;
    if (!_isValidFamilyName(value)) return FamilyNameError.invalid;
    return null;
  }

  bool _isValidFamilyName(String value) {
    return value.split('').every((char) =>
        char.toLowerCase().compareTo('a') >= 0 &&
            char.toLowerCase().compareTo('z') <= 0 ||
        'áéíóúüñ'.contains(char.toLowerCase()) ||
        char == ' ');
  }
}
