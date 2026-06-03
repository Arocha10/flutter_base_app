import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    // ignore: use_build_context_synchronously
    context.go('/login_signup');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with your splash screen design
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
