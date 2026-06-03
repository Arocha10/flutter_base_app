import 'dart:async';
import 'dart:ui';
import 'package:flutter_base_app/features/shared/preload_resources/main_preload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class PreloadManager {
  static Future<void> precacheImages() async {
    final imagePaths = MainPreload.imagePaths;

    final futures = imagePaths.map((path) {
      return _loadImage(AssetImage(path));
    }).toList();

    await _preloadSVGs(MainPreload.svgPaths);
    await Future.wait(futures);

    debugPrint('PreloadManager: all images preloaded.');
  }

  static Future<void> _loadImage(ImageProvider provider) {
    final ImageConfiguration config = ImageConfiguration(
      bundle: rootBundle,
      // ignore: deprecated_member_use
      devicePixelRatio: window.devicePixelRatio,
      platform: defaultTargetPlatform,
    );
    final Completer<void> completer = Completer<void>();
    final ImageStream stream = provider.resolve(config);

    late final ImageStreamListener listener;

    listener = ImageStreamListener((ImageInfo image, bool sync) {
      completer.complete();
      stream.removeListener(listener);
    }, onError: (Object exception, StackTrace? stackTrace) {
      completer.complete();
      stream.removeListener(listener);
      FlutterError.reportError(FlutterErrorDetails(
        context: ErrorDescription('image failed to load'),
        library: 'preload_manager',
        exception: exception,
        stack: stackTrace,
        silent: true,
      ));
    });

    stream.addListener(listener);
    return completer.future;
  }

  static Future<void> _preloadSVGs(List<String> svgPaths) async {
    for (final path in svgPaths) {
      final loader = SvgAssetLoader(path);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  }
}
