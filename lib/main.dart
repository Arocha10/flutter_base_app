import 'package:flutter_base_app/features/shared/preload_resources/preload_manager.dart';
import 'package:flutter_base_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_app/config/config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PreloadManager.precacheImages();

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ));

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0)),
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: AppTheme().getTheme(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
