// Full password recovery flow:
//   Step 1 — enter email → calls authRepository.setRecoveryCode(email)
//   Step 2 — enter 6-digit OTP → calls authRepository.verifyRecoveryCode(email, code)
//   Step 3 — enter new password → calls authRepository.updatePassword(password, accessToken)
//
// Uses newPasswordFormProvider for step 3 password validation.
// See boostr_flutter_mobile_app for the complete UI implementation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:flutter_base_app/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:flutter_base_app/features/auth/presentation/providers/reset_password_form_provider.dart';
import 'package:flutter_base_app/features/auth/domain/domain.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _showOtpFields = false;
  bool _showNewPasswordFields = false;
  String? _accessToken;
  int _countdown = 300;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _countdown = 300;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _requestOtpCode() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa un correo electrónico')));
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await ref
          .read(authRepositoryProvider)
          .setRecoveryCode(_emailController.text);

      setState(() => _showOtpFields = true);
      _startTimer();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al solicitar el código. Inténtalo de nuevo')));
      }
    }
  }

  void _verifyCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa el código de 6 dígitos')));
      return;
    }

    try {
      final UserLoginDto user = await ref
          .read(authRepositoryProvider)
          .verifyRecoveryCode(_emailController.text, int.parse(otp));

      setState(() {
        _showOtpFields = false;
        _showNewPasswordFields = true;
        _accessToken = user.token;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código incorrecto. Inténtalo de nuevo')));
      }
    }
  }

  void _updatePassword() async {
    ref.read(newPasswordFormProvider.notifier).onFormSubmit();

    final formState = ref.read(newPasswordFormProvider);
    if (!formState.newPassword.isValid || !formState.confirmNewPassword.isValid) return;

    if (formState.newPassword.value != formState.confirmNewPassword.value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }

    try {
      await ref
          .read(authRepositoryProvider)
          .updatePassword(formState.newPassword.value, _accessToken!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña actualizada correctamente')));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar la contraseña')));
      }
    }
  }

  void _handleOtpInput(int index, String value) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
    if (value.length == 1 && index == 5) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdown % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_showNewPasswordFields) {
              setState(() => _showNewPasswordFields = false);
            } else if (_showOtpFields) {
              setState(() {
                _showOtpFields = false;
                _timer?.cancel();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _showNewPasswordFields
                      ? 'Nueva Contraseña'
                      : _showOtpFields
                          ? 'Código de verificación'
                          : 'Recuperar contraseña',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (!_showOtpFields && !_showNewPasswordFields)
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),

                if (_showOtpFields) ...[
                  Text('Enviado a: ${_emailController.text}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        height: 55,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          onChanged: (value) => _handleOtpInput(index, value),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  _canResend
                      ? TextButton(
                          onPressed: _requestOtpCode,
                          child: const Text('Reenviar código'))
                      : Text('Reenviar código en $minutes:$seconds',
                          style: const TextStyle(color: Colors.grey)),
                ],

                if (_showNewPasswordFields) ...[
                  // TODO: Replace with your styled password fields using newPasswordFormProvider
                  Consumer(builder: (context, ref, _) {
                    final formState = ref.watch(newPasswordFormProvider);
                    final notifier = ref.read(newPasswordFormProvider.notifier);
                    return Column(
                      children: [
                        TextField(
                          obscureText: !formState.passwordVisible1,
                          onChanged: notifier.onNewPasswordChange,
                          decoration: InputDecoration(
                            labelText: 'Nueva contraseña',
                            border: const OutlineInputBorder(),
                            errorText: formState.isFormPosted
                                ? formState.newPassword.errorMessage
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(formState.passwordVisible1
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => notifier
                                  .onPasswordVisibilityChange1(
                                      !formState.passwordVisible1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          obscureText: !formState.passwordVisible2,
                          onChanged: notifier.onConfirmNewPasswordChange,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            border: const OutlineInputBorder(),
                            errorText: formState.isFormPosted
                                ? formState.confirmNewPassword.errorMessage
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(formState.passwordVisible2
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => notifier
                                  .onPasswordVisibilityChange2(
                                      !formState.passwordVisible2),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_showNewPasswordFields) {
                        _updatePassword();
                      } else if (_showOtpFields) {
                        _verifyCode();
                      } else {
                        _requestOtpCode();
                      }
                    },
                    child: Text(_showNewPasswordFields
                        ? 'Restablecer contraseña'
                        : _showOtpFields
                            ? 'Verificar código'
                            : 'Enviar código'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
