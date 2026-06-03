// TODO: Build your home screen here.
// The user is authenticated when this screen is reached.
// Access the logged-in user via: ref.watch(authProvider).loginUserDto

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_base_app/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are authenticated!',
                style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('User: ${authState.loginUserDto?.username ?? ''}',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
