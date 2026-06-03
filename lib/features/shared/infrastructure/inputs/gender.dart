import 'package:formz/formz.dart';

enum GenderError { empty, invalid }

class Gender extends FormzInput<String, GenderError> {
  const Gender.pure() : super.pure('');
  const Gender.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == GenderError.empty) return 'El género es requerido';
    if (displayError == GenderError.invalid) return 'El género ingresado no es válido';
    return null;
  }

  @override
  GenderError? validator(String value) {
    if (value.isEmpty) return GenderError.empty;
    return null;
  }
}
