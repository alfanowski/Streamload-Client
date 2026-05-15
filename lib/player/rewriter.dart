// lib/player/rewriter.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Result of rewriting a master playlist.
class MasterRewriteResult {
  MasterRewriteResult({required this.body, required this.renditionUrls});

  /// The rewritten m3u8 text.
  final String body;

  /// Map from label (the path segment used in `/video/{label}.m3u8`) to
  /// the original upstream URL the master playlist pointed at.
  final Map<String, String> renditionUrls;
}

/// Result of rewriting a media (variant) playlist.
class MediaRewriteResult {
  MediaRewriteResult(
      {required this.body, required this.keyUrl, required this.segmentUrls});

  /// The rewritten m3u8 text.
  final String body;

  /// The original upstream AES-128 key URL (if present in the playlist).
  final String? keyUrl;

  /// Upstream URLs for each segment, in playlist order.
  /// Index matches the `{n}` in `/seg/{rendition}/{n}.ts`.
  final List<String> segmentUrls;
}

/// Pure m3u8 rewriting. No IO. Mirrors the v2 backend's
/// `streamload/streaming/m3u8_rewrite.py` 1:1 in semantics.
class Rewriter {
  static final _streamInf = RegExp(r'^#EXT-X-STREAM-INF:.*$', multiLine: true);
  static final _renditionParam = RegExp(r'rendition=([^&"\s]+)');
  static final _uriAttr = RegExp(r'URI="([^"]+)"');
  static final _typeAttr = RegExp(r'TYPE=(\w+)');
  static final _languageAttr = RegExp(r'LANGUAGE="([^"]+)"');
  static final _subsAttrInline = RegExp(r',?\s*SUBTITLES="[^"]*"');
  static final _strayLeadingComma = RegExp(r':\s*,');

  // Suppress lint: field is used via reflection pattern in regex usage.
  // ignore: unused_field
  static final _unused = _streamInf;

  /// Rewrite a master playlist. Audio MEDIA URIs become
  /// `{basePath}/audio/{lang}.m3u8`. Video STREAM-INF lines get a
  /// `{basePath}/video/{label}.m3u8` URL on the next line. SUBTITLES
  /// MEDIA tags are dropped entirely (and STREAM-INF SUBTITLES="..."
  /// attributes scrubbed).
  ///
  /// Returns a [MasterRewriteResult] with the rewritten body and a map from
  /// rendition label to original upstream URL (for later variant fetching).
  static MasterRewriteResult rewriteMaster(String text,
      {required String basePath}) {
    final lines = const LineSplitter().convert(text);
    final out = <String>[];
    final renditionUrls = <String, String>{};
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
          final uri = _uriAttr.firstMatch(line)?.group(1);
          if (lang != null && uri != null) {
            // Stash the upstream URL under "audio:<lang>" so the proxy can
            // look it up when the audio variant is requested.
            renditionUrls['audio:$lang'] = uri;
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
            final label = _labelFor(upstream);
            renditionUrls[label] = upstream;
            out.add('$basePath/video/$label.m3u8');
            i++; // skip the original URL
          }
        }
        continue;
      }

      out.add(line);
    }
    return MasterRewriteResult(
        body: out.join('\n'), renditionUrls: renditionUrls);
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
  ///
  /// Returns a [MediaRewriteResult] with the rewritten body, the original
  /// key URL (if any), and the list of original segment URLs in order.
  static MediaRewriteResult rewriteMedia(
    String text, {
    required String rendition,
    required String basePath,
  }) {
    final lines = const LineSplitter().convert(text);
    final out = <String>[];
    String? keyUrl;
    final segmentUrls = <String>[];
    var segIndex = 0;
    for (final line in lines) {
      if (line.startsWith('#EXT-X-KEY:')) {
        final m = _uriAttr.firstMatch(line);
        if (m != null) keyUrl = m.group(1);
        final replaced = line.replaceFirstMapped(
          _uriAttr,
          (_) => 'URI="$basePath/key/$rendition"',
        );
        out.add(replaced);
        continue;
      }
      if (line.isNotEmpty && !line.startsWith('#')) {
        segmentUrls.add(line);
        out.add('$basePath/seg/$rendition/$segIndex.ts');
        segIndex++;
        continue;
      }
      out.add(line);
    }
    return MediaRewriteResult(
        body: out.join('\n'), keyUrl: keyUrl, segmentUrls: segmentUrls);
  }
}
