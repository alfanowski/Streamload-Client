// lib/app.dart
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player/engine.dart';
import 'plugins/updater.dart';
import 'presentation/theme/theme.dart';
import 'presentation/widgets/splash/splash_gate.dart';
import 'router.dart';
import 'state/auth_provider.dart';
import 'state/local_proxy_provider.dart';

class StreamloadApp extends ConsumerStatefulWidget {
  const StreamloadApp({super.key});

  @override
  ConsumerState<StreamloadApp> createState() => _StreamloadAppState();
}

class _StreamloadAppState extends ConsumerState<StreamloadApp> {
  @override
  void initState() {
    super.initState();
    // Kick off bootstrap so the redirect logic in router has a real state.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(authProvider.notifier).bootstrap();
      // Once auth is settled, start the plugin update tick. Safe to call even
      // if the user has no PAT yet — the loader will throw and the updater
      // will skip the tick gracefully.
      ref.read(pluginUpdaterProvider).start();
      // Initialize media_kit native libraries (no-op if already done).
      PlayerEngine.ensureInitialized();
      // Warm up the local HLS proxy so it is ready before the first playback.
      unawaited(ref.read(localProxyProvider.future));
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Streamload',
      theme: streamloadTheme(),
      darkTheme: streamloadTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _StreamloadScrollBehavior(),
      // Cold-start splash: the "Streamload" wordmark draws itself, then
      // dissolves smoothly to reveal the app (already mounted behind it).
      builder: (context, child) =>
          SplashGate(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// App-wide scroll behavior: NO scrollbars anywhere (operator wants the
/// desktop scrollbar gone), and mouse-drag scrolling enabled so rows/pages
/// can be dragged with the pointer on desktop, not just the wheel.
class _StreamloadScrollBehavior extends MaterialScrollBehavior {
  const _StreamloadScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
