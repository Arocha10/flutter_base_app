import 'package:formz/formz.dart';

enum DateOfBirthError { empty, invalidFormat, tooYoung }

class DateOfBirth extends FormzInput<String, DateOfBirthError> {
  const DateOfBirth.pure() : super.pure('');
  const DateOfBirth.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == DateOfBirthError.empty) return 'La fecha de nacimiento es requerida';
    return null;
  }

  @override
  DateOfBirthError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return DateOfBirthError.empty;
    return null;
  }
}
