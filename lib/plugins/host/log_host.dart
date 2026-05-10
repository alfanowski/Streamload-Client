// lib/plugins/host/log_host.dart
import '../../infra/logger.dart';

typedef LogSink = void Function(LogLevel level, String tag, String message);

class LogHost {
  /// `sink` defaults to the project's Logger; tests can inject a capture sink.
  LogHost({LogSink? sink}) : _sink = sink ?? _defaultSink;

  final LogSink _sink;

  void handle(String pluginShortName, String level, String message) {
    final lvl = switch (level) {
      'debug' => LogLevel.debug,
      'info' => LogLevel.info,
      'warn' => LogLevel.warn,
      'error' => LogLevel.error,
      _ => LogLevel.info,
    };
    _sink(lvl, 'plugin:$pluginShortName', message);
  }

  static void _defaultSink(LogLevel level, String tag, String message) {
    final logger = Logger(tag);
    switch (level) {
      case LogLevel.debug:
        logger.debug(message);
      case LogLevel.info:
        logger.info(message);
      case LogLevel.warn:
        logger.warn(message);
      case LogLevel.error:
        logger.error(message);
    }
  }
}
