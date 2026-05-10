// lib/player/rewriter.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Pure m3u8 rewriting. No IO. Mirrors the v2 backend's
/// `streamload/streaming/m3u8_rewrite.py` 1:1 in semantics.
class Rewriter {
  static final _streamInf = RegExp(r'^#EXT-X-STREAM-INF:.*$', multiLine: true);
  static final _renditionParam = RegExp(r'rendition=([^&"\s]+)');
  static final _uriAttr = RegExp(r'URI="([^"]+)"');
  static final _typeAttr = RegExp(r'TYPE=(\w+)');
  static final _languageAttr = RegExp(r'LANGUAGE="([^"]+)"');
  static final _subsAttrInline =
      RegExp(r',?\s*SUBTITLES="[^"]*"');
  static final _strayLeadingComma = RegExp(r':\s*,');

  /// Rewrite a master playlist. Audio MEDIA URIs become
  /// `{basePath}/audio/{lang}.m3u8`. Video STREAM-INF lines get a
  /// `{basePath}/video/{label}.m3u8` URL on the next line. SUBTITLES
  /// MEDIA tags are dropped entirely (and STREAM-INF SUBTITLES="..."
  /// attributes scrubbed).
  static String rewriteMaster(String text, {required String basePath}) {
    final lines = const LineSplitter().convert(text);
    final out = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('#EXT-X-MEDIA:')) {
        final type = _typeAttr.firstMatch(line)?.group(1);
        if (type == 'SUBTITLES') {
          // Drop entirely.
          continue;
        }
        if (type == 'AUDIO') {
          final lang = _languageAttr.firstMatch(line)?.group(1);
          if (lang != null) {
            final replaced = line.replaceFirstMapped(
              _uriAttr,
              (_) => 'URI="$basePath/audio/$lang.m3u8"',
            );
            out.add(replaced);
            continue;
          }
        }
        out.add(line);
        continue;
      }

      if (line.startsWith('#EXT-X-STREAM-INF:')) {
        var cleaned = line.replaceAll(_subsAttrInline, '');
        cleaned = cleaned.replaceAll(_strayLeadingComma, ':');
        out.add(cleaned);
        // Next line is the upstream URL — replace it.
        if (i + 1 < lines.length) {
          final upstream = lines[i + 1].trim();
          if (upstream.isNotEmpty && !upstream.startsWith('#')) {
            out.add('$basePath/video/${_labelFor(upstream)}.m3u8');
            i++; // skip the original URL
          }
        }
        continue;
      }

      out.add(line);
    }
    return out.join('\n');
  }

  static String _labelFor(String url) {
    final m = _renditionParam.firstMatch(url);
    if (m != null) return m.group(1)!;
    final hash = sha1.convert(utf8.encode(url)).toString();
    return hash.substring(0, 8);
  }

  /// Rewrite a media (variant) playlist. Segment URIs become
  /// `{basePath}/seg/{rendition}/{n}.ts`. AES-128 key URIs become
  /// `{basePath}/key/{rendition}` (the IV attribute is preserved).
  static String rewriteMedia(
    String text, {
    required String rendition,
    required String basePath,
  }) {
    final lines = const LineSplitter().convert(text);
    final out = <String>[];
    var segIndex = 0;
    for (final line in lines) {
      if (line.startsWith('#EXT-X-KEY:')) {
        final replaced = line.replaceFirstMapped(
          _uriAttr,
          (_) => 'URI="$basePath/key/$rendition"',
        );
        out.add(replaced);
        continue;
      }
      if (line.isNotEmpty && !line.startsWith('#')) {
        out.add('$basePath/seg/$rendition/$segIndex.ts');
        segIndex++;
        continue;
      }
      out.add(line);
    }
    return out.join('\n');
  }
}
