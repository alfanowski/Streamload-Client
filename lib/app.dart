// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'plugins/updater.dart';
import 'presentation/theme/theme.dart';
import 'router.dart';
import 'state/auth_provider.dart';

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
    );
  }
}
