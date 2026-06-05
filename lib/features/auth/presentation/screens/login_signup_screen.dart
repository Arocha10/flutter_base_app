// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_base_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_base_app/features/auth/presentation/providers/providers.dart';
import 'package:flutter_base_app/features/auth/auth.dart';
import 'package:flutter_base_app/features/shared/styled_text.dart';
import 'package:flutter_base_app/features/shared/widgets/loader_widget.dart';
import '../widgets/inline_gender_generator.dart';

// URLs — replace with your own
const String _termsUrl = 'https://YOUR_TERMS_URL';
const String _privacyUrl = 'https://YOUR_PRIVACY_URL';

final BoxDecoration _buttonShadowDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(40),
  boxShadow: const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      spreadRadius: 1,
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ],
);

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login_signup/login_signup_background.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          const _RegisterScreen(),
        ],
      ),
    );
  }
}

class _RegisterScreen extends ConsumerWidget {
  const _RegisterScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Stack(
      children: [
        const DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _CustomAppBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _LoginCard(),
                    _SignupCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (authState.isAuthenticating)
          Positioned.fill(
            child: SlideInDown(
              child: const CustomLoader(size: 2.5),
            ),
          ),
      ],
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth * 0.8;
            const tabTextSize = 14.5;
            final logoHeight = constraints.maxHeight * 0.18;

            return Container(
              width: maxWidth > 300 ? 300 : maxWidth,
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 0),
                    child: FadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(seconds: 1),
                      child: Image.asset(
                        'assets/images/logo/black_logo.png',
                        height: logoHeight > 150 ? 150 : logoHeight,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.black,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                          fontFamily: 'AvenirRegular', fontSize: tabTextSize),
                      tabs: const [
                        Tab(text: 'Iniciar sesión', height: 32),
                        Tab(text: 'Registrarse', height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(builder: (context, constraints) {
          final cardWidth = constraints.maxWidth * 0.8;
          return Card(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.05, vertical: 0.5),
              child: const SingleChildScrollView(
                child: _LoginForm(),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SignupCard extends StatelessWidget {
  const _SignupCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(builder: (context, constraints) {
          final cardWidth = constraints.maxWidth * 0.8;
          return Card(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.05, vertical: 1),
              child: const SingleChildScrollView(
                child: _RegisterForm(),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Login Form
// ---------------------------------------------------------------------------

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
              fontFamily: 'AvenirRegular', fontSize: 14.0, color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      _showSnackbar(context, next.errorMessage);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Form(
          child: Column(
            children: [
              _buildTextFields(ref, width * 0.8),
              const SizedBox(height: 14),
              _buildForgotPasswordButton(context),
              const SizedBox(height: 14),
              _buildMainButton(ref),
              const SizedBox(height: 27),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(child: Container(height: 1, color: Colors.white)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: StyledText('O entra con', Colors.white, 15),
                    ),
                    Expanded(child: Container(height: 1, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _buildSocialButtons(ref),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextFields(WidgetRef ref, double maxWidth) {
    final loginForm = ref.watch(loginFormProvider);

    return Column(
      children: [
        _buildTextField(
          'Correo electrónico o usuario',
          'Ej: juanpirod23@gmail.com',
          TextInputType.text,
          loginForm.usernameOrEmail.value,
          ref.read(loginFormProvider.notifier).onEmailChange,
          loginForm.isFormPosted ? loginForm.usernameOrEmail.errorMessage : null,
          maxWidth,
        ),
        _buildPasswordField(
          'Contraseña',
          loginForm.password.value,
          ref.read(loginFormProvider.notifier).onPasswordChange,
          loginForm.passwordVisible,
          ref.read(loginFormProvider.notifier).onPasswordVisibilityChange,
          loginForm.isFormPosted ? loginForm.password.errorMessage : null,
          maxWidth,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextInputType keyboardType,
    String initialValue,
    Function(String) onChanged,
    String? errorText,
    double maxWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(label, Colors.black, 13.5),
        const SizedBox(height: 0.5),
        SizedBox(
          width: maxWidth,
          child: CustomTextFormField(
            height: 30,
            fillColor: Colors.black,
            hint: hint,
            hintColor: const Color.fromARGB(255, 216, 206, 206),
            textColor: Colors.white,
            showSuffixIcon: false,
            enabled: true,
            keyboardType: keyboardType,
            errorText: errorText,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    String value,
    void Function(String) onChanged,
    bool passwordVisible,
    Function(bool) onVisibilityChange,
    String? errorText,
    double maxWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(label, Colors.black, 13.5),
        const SizedBox(height: 0.5),
        SizedBox(
          width: maxWidth,
          child: CustomTextFormField(
            initialValue: value,
            onChanged: onChanged,
            height: 30,
            fillColor: Colors.black,
            obscureText: !passwordVisible,
            hint: '********',
            hintColor: const Color.fromARGB(255, 216, 206, 206),
            textColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => onVisibilityChange(!passwordVisible),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton(WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

    return Container(
      decoration: _buttonShadowDecoration,
      child: FilledButton.tonalIcon(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            return loginForm.isMainButtonPressed ? Colors.black : Colors.white;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            return loginForm.isMainButtonPressed ? Colors.white : Colors.black;
          }),
          minimumSize: WidgetStateProperty.all(const Size(55, 35)),
        ),
        onPressed: loginForm.isPosting
            ? null
            : ref.read(loginFormProvider.notifier).onMainButtonPress,
        label: const Text(
          'Iniciar sesión',
          style: TextStyle(fontFamily: 'AvenirRegular', fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSocialButtons(WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final authState = ref.watch(authProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: _buildSocialButton(
            'assets/images/login_signup/google_logo.png',
            'Google',
            loginForm.isGoogleButtonPressed,
            authState.isAuthenticating
                ? null
                : () => ref
                    .read(loginFormProvider.notifier)
                    .onGoogleButtonChange(),
            isAppleButton: false,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 130,
          child: _buildSocialButton(
            'assets/images/login_signup/apple_logo.png',
            'Apple',
            loginForm.isAppleButtonPressed,
            authState.isAuthenticating
                ? null
                : () =>
                    ref.read(loginFormProvider.notifier).onAppleButtonChange(),
            isAppleButton: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String assetName,
    String text,
    bool isPressed,
    VoidCallback? onPressed, {
    bool isAppleButton = false,
  }) {
    return FilledButton.tonalIcon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return isPressed
              ? Colors.black
              : const Color.fromRGBO(255, 255, 255, 0.5);
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return isPressed ? Colors.white : Colors.black;
        }),
        minimumSize: WidgetStateProperty.all(const Size(100, 30)),
      ),
      onPressed: onPressed,
      icon: isAppleButton
          ? ImageIcon(AssetImage(assetName), size: 15)
          : SizedBox(
              width: 15,
              height: 15,
              child: Image.asset(assetName, fit: BoxFit.contain),
            ),
      label: Text(
        text,
        style:
            const TextStyle(fontFamily: 'AvenirRegular', letterSpacing: -0.3),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 35,
      child: TextButton(
        onPressed: () => context.push('/password_recovery_screen'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
        ),
        child: const Text(
          '¿Has olvidado tu contraseña?',
          style: TextStyle(
            fontFamily: 'AvenirRegular',
            color: Colors.black,
            fontSize: 15,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Register Form
// ---------------------------------------------------------------------------

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm();

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  late final FocusNode _nameFocusNode;
  late final FocusNode _lastNameFocusNode;
  late final FocusNode _usernameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final FocusNode _confirmPasswordFocusNode;

  final List<String> _genderOptions = const [
    'Masculino',
    'Femenino',
    'Prefiero no decirlo',
  ];

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _usernameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
              fontFamily: 'AvenirRegular', fontSize: 14, color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showGenderSelectorDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: InlineGenderSelector(
            selectedGender:
                ref.watch(signupFormProvider).selectedGender.value.isNotEmpty
                    ? ref.watch(signupFormProvider).selectedGender.value
                    : null,
            genders: _genderOptions,
            onGenderSelected: (gender) {
              ref
                  .read(signupFormProvider.notifier)
                  .onSelectedGenderChange(gender);
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _showDatePickerDialog(BuildContext context) async {
    final signupForm = ref.read(signupFormProvider);
    DateTime initialDateValue;

    if (signupForm.selectedDate.value.isNotEmpty) {
      try {
        initialDateValue = DateTime.parse(signupForm.selectedDate.value);
      } catch (_) {
        initialDateValue = DateTime(2000, 1, 15);
      }
    } else {
      initialDateValue = DateTime(2000, 1, 15);
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: InlineDatePicker(
            initialDate: initialDateValue,
            onDateChanged: (newDate) {
              ref.read(signupFormProvider.notifier).onSelectedDateChange(
                    newDate.toIso8601String().substring(0, 10),
                  );
            },
            title: 'Fecha de nacimiento',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Focus management listener
    ref.listen<SignupFormState>(signupFormProvider, (previous, next) {
      if (previous?.fieldToFocus == next.fieldToFocus ||
          next.fieldToFocus == SignupFieldToFocus.none) return;

      switch (next.fieldToFocus) {
        case SignupFieldToFocus.name:
          _nameFocusNode.requestFocus();
          break;
        case SignupFieldToFocus.lastName:
          _lastNameFocusNode.requestFocus();
          break;
        case SignupFieldToFocus.username:
          _usernameFocusNode.requestFocus();
          break;
        case SignupFieldToFocus.email:
          _emailFocusNode.requestFocus();
          break;
        case SignupFieldToFocus.password:
          _passwordFocusNode.requestFocus();
          break;
        case SignupFieldToFocus.confirmPassword:
          _confirmPasswordFocusNode.requestFocus();
          break;
        case SignupFieldToFocus.none:
          break;
      }
      ref.read(signupFormProvider.notifier).clearFocus();
    });

    // Auth error listener
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      _showSnackbar(context, next.errorMessage);
    });

    // Signup validation error listener
    ref.listen<SignupFormState>(signupFormProvider, (previous, next) {
      if (next.validationError.isNotEmpty) {
        _showSnackbar(context, next.validationError);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Form(
          child: Column(
            children: [
              _buildTextFields(context, width * 0.8),
              const SizedBox(height: 10),
              _buildTermsAndPrivacyCheckboxes(),
              const SizedBox(height: 10),
              _buildMainButton(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(height: 1, color: Colors.white)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: StyledText('O entra con', Colors.white, 15),
                    ),
                    Expanded(
                        child: Container(height: 1, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildSocialButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextFields(BuildContext context, double maxWidth) {
    final signupForm = ref.watch(signupFormProvider);

    return Column(
      children: [
        _buildTextField(
          'Nombre (s)',
          'Ej: Juan Pablo',
          TextInputType.text,
          ref.read(signupFormProvider.notifier).onNameChange,
          signupForm.isFormPosted ? signupForm.givenName.errorMessage : null,
          maxWidth,
          focusNode: _nameFocusNode,
        ),
        const SizedBox(height: 6),
        _buildTextField(
          'Apellidos',
          'Ej: Rodriguez Perez',
          TextInputType.text,
          ref.read(signupFormProvider.notifier).onLastNameChange,
          signupForm.isFormPosted ? signupForm.familyName.errorMessage : null,
          maxWidth,
          focusNode: _lastNameFocusNode,
        ),
        const SizedBox(height: 6),
        _buildTextField(
          'Nombre de usuario',
          'Ej: juanpa_23',
          TextInputType.text,
          ref.read(signupFormProvider.notifier).onUsernameChange,
          signupForm.isFormPosted ? signupForm.username.errorMessage : null,
          maxWidth,
          focusNode: _usernameFocusNode,
        ),
        const SizedBox(height: 6),
        _buildTextField(
          'Correo electrónico',
          'Ej: juanpirod23@gmail.com',
          TextInputType.emailAddress,
          ref.read(signupFormProvider.notifier).onEmailChange,
          signupForm.isFormPosted ? signupForm.email.errorMessage : null,
          maxWidth,
          focusNode: _emailFocusNode,
        ),
        const SizedBox(height: 6),
        _buildDatePicker(context, maxWidth),
        const SizedBox(height: 6),
        _buildGenderPicker(context, maxWidth),
        const SizedBox(height: 6),
        _buildPasswordField(
          'Contraseña',
          signupForm.password.value,
          ref.read(signupFormProvider.notifier).onPasswordChange,
          signupForm.passwordVisible1,
          ref.read(signupFormProvider.notifier).onPasswordVisibilityChange1,
          signupForm.isFormPosted ? signupForm.password.errorMessage : null,
          maxWidth,
          focusNode: _passwordFocusNode,
        ),
        const SizedBox(height: 6),
        _buildPasswordField(
          'Confirmar contraseña',
          signupForm.confirmPassword.value,
          ref.read(signupFormProvider.notifier).onConfirmPasswordChange,
          signupForm.passwordVisible2,
          ref.read(signupFormProvider.notifier).onPasswordVisibilityChange2,
          signupForm.isFormPosted
              ? signupForm.confirmPassword.errorMessage
              : null,
          maxWidth,
          focusNode: _confirmPasswordFocusNode,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextInputType keyboardType,
    void Function(String) onChanged,
    String? errorText,
    double maxWidth, {
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(label, Colors.black, 14),
        const SizedBox(height: 0.5),
        SizedBox(
          width: maxWidth,
          child: CustomTextFormField(
            focusNode: focusNode,
            onChanged: onChanged,
            height: 30,
            fillColor: Colors.black,
            hint: hint,
            hintColor: const Color.fromARGB(255, 216, 206, 206),
            textColor: Colors.white,
            showSuffixIcon: false,
            enabled: true,
            keyboardType: keyboardType,
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    String value,
    void Function(String) onChanged,
    bool passwordVisible,
    Function(bool) onVisibilityChange,
    String? errorText,
    double maxWidth, {
    required FocusNode focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText(label, Colors.black, 14),
        const SizedBox(height: 0.5),
        SizedBox(
          width: maxWidth,
          child: CustomTextFormField(
            focusNode: focusNode,
            initialValue: value,
            onChanged: onChanged,
            height: 30,
            fillColor: Colors.black,
            obscureText: !passwordVisible,
            hint: '********',
            hintColor: const Color.fromARGB(255, 216, 206, 206),
            textColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => onVisibilityChange(!passwordVisible),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, double maxWidth) {
    final signupForm = ref.watch(signupFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText('Fecha de nacimiento', Colors.black, 14),
        const SizedBox(height: 0.5),
        SizedBox(
          width: maxWidth,
          child: CustomDatePicker(
            selectedDate: signupForm.selectedDate.value,
            onTap: () => _showDatePickerDialog(context),
            fillColor: Colors.black,
            hintColor: const Color.fromARGB(255, 216, 206, 206),
            textColor: Colors.white,
          ),
        ),
        if (signupForm.isFormPosted &&
            signupForm.selectedDate.errorMessage != null)
          _buildErrorWidget(signupForm.selectedDate.errorMessage!),
      ],
    );
  }

  Widget _buildGenderPicker(BuildContext context, double maxWidth) {
    final signupForm = ref.watch(signupFormProvider);
    final currentSelectedGender = signupForm.selectedGender.value;
    final bool hasError =
        signupForm.isFormPosted && signupForm.selectedGender.errorMessage != null;

    const Color fillColor = Colors.black;
    const Color textColor = Colors.white;
    const Color hintColor = Color.fromARGB(255, 216, 206, 206);
    const TextStyle textStyle =
        TextStyle(fontFamily: 'AvenirRegular', color: textColor, fontSize: 14);
    const TextStyle hintStyle =
        TextStyle(fontFamily: 'AvenirRegular', color: hintColor, fontSize: 14);
    final BorderRadius borderRadius = BorderRadius.circular(20.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StyledText('Género', Colors.black, 14),
        const SizedBox(height: 0.5),
        GestureDetector(
          onTap: () => _showGenderSelectorDialog(context),
          child: Container(
            width: maxWidth,
            height: 30.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(color: fillColor, borderRadius: borderRadius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currentSelectedGender.isNotEmpty
                        ? currentSelectedGender
                        : 'Selecciona tu género',
                    style: currentSelectedGender.isNotEmpty
                        ? textStyle
                        : hintStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
        if (hasError)
          _buildErrorWidget(signupForm.selectedGender.errorMessage!),
      ],
    );
  }

  Widget _buildTermsAndPrivacyCheckboxes() {
    final signupForm = ref.watch(signupFormProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxWithText(
          signupForm.acceptTerms1.value,
          (val) => ref.read(signupFormProvider.notifier).onTerms1Change(val),
          'Al aceptar, estás de acuerdo con nuestros ',
          'términos y condiciones',
          _termsUrl,
          ' para un uso responsable y seguro de esta app.',
          signupForm.isFormPosted ? signupForm.acceptTerms1.errorMessage : null,
        ),
        const SizedBox(height: 4),
        _buildCheckboxWithText(
          signupForm.acceptTerms2.value,
          (val) => ref.read(signupFormProvider.notifier).onTerms2Change(val),
          'Estamos comprometidos con la privacidad. Al seguir, confirmas que has leído y aceptas nuestra ',
          'política de privacidad',
          _privacyUrl,
          '.',
          signupForm.isFormPosted ? signupForm.acceptTerms2.errorMessage : null,
        ),
      ],
    );
  }

  Widget _buildCheckboxWithText(
    bool value,
    Function(bool) onChanged,
    String beforeLinkText,
    String linkText,
    String url,
    String afterLinkText,
    String? errorText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 12,
                child: CheckboxTheme(
                  data: CheckboxThemeData(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Colors.black, width: 1.5),
                    fillColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.black;
                      }
                      return null;
                    }),
                    checkColor:
                        WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return null;
                    }),
                  ),
                  child: Checkbox(
                    value: value,
                    onChanged: (val) => onChanged(val!),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                    ),
                    children: [
                      TextSpan(text: beforeLinkText),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => _launchUrl(url),
                          child: Text(
                            linkText,
                            style: const TextStyle(
                              color: Color.fromRGBO(80, 80, 211, 1),
                              fontSize: 10.4,
                              decoration: TextDecoration.underline,
                              decorationColor: Color.fromRGBO(80, 80, 211, 1),
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: afterLinkText),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (errorText != null) _buildErrorWidget(errorText),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Widget _buildMainButton() {
    final signupForm = ref.watch(signupFormProvider);
    return Container(
      decoration: _buttonShadowDecoration,
      child: FilledButton.tonalIcon(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            return signupForm.isMainButtonPressed ? Colors.black : Colors.white;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            return signupForm.isMainButtonPressed ? Colors.white : Colors.black;
          }),
          minimumSize: WidgetStateProperty.all(const Size(30, 30)),
        ),
        onPressed: signupForm.isPosting
            ? null
            : ref.read(signupFormProvider.notifier).onMainButtonPress,
        label: const Text(
          'Crear Cuenta',
          style: TextStyle(fontFamily: 'AvenirRegular'),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    final signupForm = ref.watch(signupFormProvider);
    final authState = ref.watch(authProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          'assets/images/login_signup/google_logo.png',
          signupForm.isGoogleButtonPressed,
          authState.isAuthenticating
              ? null
              : () =>
                  ref.read(signupFormProvider.notifier).onGoogleButtonChange(),
          isAppleButton: false,
        ),
        const SizedBox(width: 25),
        _buildSocialButton(
          'assets/images/login_signup/apple_logo.png',
          signupForm.isAppleButtonPressed,
          authState.isAuthenticating
              ? null
              : () =>
                  ref.read(signupFormProvider.notifier).onAppleButtonChange(),
          isAppleButton: true,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String assetName,
    bool isPressed,
    VoidCallback? onPressed, {
    bool isAppleButton = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 3.0, bottom: 20.0, left: 2, right: 2),
      child: IconButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              const Color.fromRGBO(255, 255, 255, 0.5)),
          padding: WidgetStateProperty.all(const EdgeInsets.all(8.0)),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        icon: isAppleButton
            ? ImageIcon(AssetImage(assetName), size: 20)
            : Image.asset(assetName,
                width: 20, height: 20, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildErrorWidget(String errorText) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 5),
      child: Text(
        errorText,
        style: const TextStyle(
            color: Colors.red, fontFamily: 'AvenirRegular', fontSize: 11),
      ),
    );
  }
}
