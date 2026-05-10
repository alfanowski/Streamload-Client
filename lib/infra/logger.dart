// lib/infra/logger.dart
//
// Tiny structured logger. Debug builds print to stdout; release strips info+below.

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warn, error }

class Logger {
  Logger(this.tag);
  final String tag;

  void debug(String msg) => _log(LogLevel.debug, msg);
  void info(String msg) => _log(LogLevel.info, msg);
  void warn(String msg) => _log(LogLevel.warn, msg);
  void error(String msg, [Object? err, StackTrace? st]) {
    _log(LogLevel.error, '$msg${err != null ? ' — $err' : ''}');
    if (kDebugMode && st != null) debugPrint(st.toString());
  }

  void _log(LogLevel level, String msg) {
    if (!kDebugMode && level.index < LogLevel.warn.index) return;
    debugPrint('[${level.name.toUpperCase()}] $tag: $msg');
  }
}
