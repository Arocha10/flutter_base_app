import 'package:formz/formz.dart';

enum PoliciesError { notAccepted }

class Policies extends FormzInput<bool, PoliciesError> {
  const Policies.pure() : super.pure(false);
  const Policies.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == PoliciesError.notAccepted) return 'Debes aceptar nuestra política de privacidad';
    return null;
  }

  @override
  PoliciesError? validator(bool value) {
    if (!value) return PoliciesError.notAccepted;
    return null;
  }
}
