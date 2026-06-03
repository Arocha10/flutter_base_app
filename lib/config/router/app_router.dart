import 'package:flutter_base_app/config/router/app_router_notifier.dart';
import 'package:flutter_base_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_base_app/features/auth/presentation/screens/check_auth_status_screen.dart';
import 'package:flutter_base_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter_base_app/features/auth/presentation/screens/onboarding_screen/onboarding_screen.dart';
import 'package:flutter_base_app/features/auth/presentation/screens/splash/splash_screen.dart';
import 'package:flutter_base_app/features/auth/auth.dart';
import 'package:flutter_base_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.watch(goRouterNotifierProvider);
  var logger = Logger();

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login_signup',
        builder: (context, state) => const LoginSignupScreen(),
      ),
      GoRoute(
        path: '/splash_auth',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),
      GoRoute(
        path: '/password_recovery_screen',
        builder: (context, state) => const PasswordRecoveryScreen(),
      ),

      // TODO: Add your app routes here
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) async {
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('hasCompletedOnboarding') ?? false;

      logger.i(
          'Router redirect — isGoingTo: $isGoingTo | authStatus: $authStatus | onboarding: $hasCompletedOnboarding');

      // While auth is being checked, stay on splash
      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      // Not authenticated
      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/password_recovery_screen') return null;
        if (isGoingTo == '/login_signup') return null;
        if (!hasCompletedOnboarding) return '/onboarding';
        return '/login_signup';
      }

      // Authenticated — redirect away from auth screens
      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login_signup' ||
            isGoingTo == '/splash' ||
            isGoingTo == '/onboarding') {
          return '/home';
        }
      }

      return null;
    },
  );
});
