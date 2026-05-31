// lib/main.dart
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'player/engine.dart';

void main() {
  // media_kit MUST be initialized before ANY Player() is constructed. Doing it
  // here (before runApp) — rather than in a post-frame callback after async
  // bootstrap — guarantees the native libmpv backend is ready by the time the
  // first WatchPage builds its player. Otherwise the Player() constructor
  // throws "MediaKit.ensureInitialized must be called…".
  WidgetsFlutterBinding.ensureInitialized();
  PlayerEngine.ensureInitialized();

  // The whole app is portrait-locked. The ONLY landscape surface is the video
  // player (WatchPage), which opts into landscape on entry and restores this
  // portrait lock on exit. Set it before runApp so the very first frame is
  // already constrained.
  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  // iOS: put the audio session in "playback" so the player's sound is actually
  // audible and ignores the silent switch (without this, video plays muted).
  _configureAudioSession();

  runApp(const ProviderScope(child: StreamloadApp()));
}

Future<void> _configureAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  // configure() only sets the category — the session must be ACTIVATED for
  // iOS to actually route the player's audio to the output. Without this the
  // video decodes audio but stays silent.
  await session.setActive(true);
}
