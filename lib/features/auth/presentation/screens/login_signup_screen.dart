// TODO: Replace this placeholder with your Login/Signup UI.
// The providers (loginFormProvider, signupFormProvider, authProvider) are all
// wired up — just build your UI on top of them.
//
// See the boostr_flutter_mobile_app repo for a full reference implementation.

import 'package:flutter/material.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Sign Up'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LoginTab(),
            _SignupTab(),
          ],
        ),
      ),
    );
  }
}

class _LoginTab extends StatelessWidget {
  const _LoginTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Build your login UI using loginFormProvider
    return const Center(
      child: Text('Login — wire up loginFormProvider'),
    );
  }
}

class _SignupTab extends StatelessWidget {
  const _SignupTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Build your signup UI using signupFormProvider
    return const Center(
      child: Text('Sign Up — wire up signupFormProvider'),
    );
  }
}
