// lib/plugins/host/json_host.dart
import 'dart:convert';

class JsonHost {
  JsonHost._();

  static Object? parse(String text) => jsonDecode(text);

  static String stringify(Object? value) => jsonEncode(value);
}
