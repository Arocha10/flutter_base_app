import 'package:formz/formz.dart';

enum EmailError { empty, format, alreadyExists }

class Email extends FormzInput<String, EmailError> {
  final bool isAlreadyInUse;

  static final RegExp emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  const Email.pure({this.isAlreadyInUse = false}) : super.pure('');
  const Email.dirty(super.value, {this.isAlreadyInUse = false}) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == EmailError.empty) return 'El correo electrónico es requerido';
    if (displayError == EmailError.format) return 'No tiene formato de correo electrónico';
    if (displayError == EmailError.alreadyExists) return 'El correo ya se encuentra registrado';
    return null;
  }

  @override
  EmailError? validator(String value) {
    if (isAlreadyInUse) return EmailError.alreadyExists;
    if (value.isEmpty || value.trim().isEmpty) return EmailError.empty;
    if (!emailRegExp.hasMatch(value)) return EmailError.format;
    return null;
  }
}
