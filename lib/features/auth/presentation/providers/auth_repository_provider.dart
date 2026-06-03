import 'package:flutter_base_app/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
