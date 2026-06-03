import 'package:formz/formz.dart';

enum UsernameOrEmailError { empty }

class UsernameOrEmail extends FormzInput<String, UsernameOrEmailError> {
  const UsernameOrEmail.pure() : super.pure('');
  const UsernameOrEmail.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == UsernameOrEmailError.empty) return 'El campo es requerido';
    return null;
  }

  @override
  UsernameOrEmailError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return UsernameOrEmailError.empty;
    return null;
  }
}
