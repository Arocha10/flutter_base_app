import 'package:flutter_base_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

var logger = Logger();

final goRouterNotifierProvider = Provider((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  logger.i('AppRouterNotifierProvider: returning GoRouterNotifier');
  return GoRouterNotifier(authNotifier);
});

class GoRouterNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;

  AuthStatus _authStatus = AuthStatus.checking;

  GoRouterNotifier(this._authNotifier) {
    logger.i('GoRouterNotifier: constructor');
    _authNotifier.addListener((state) {
      authStatus = state.authStatus;
    });
  }

  AuthStatus get authStatus => _authStatus;

  set authStatus(AuthStatus value) {
    logger.i('AppRouterNotifier: setting authStatus: $value');
    _authStatus = value;
    notifyListeners();
  }
}
