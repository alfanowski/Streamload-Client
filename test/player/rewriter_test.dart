// test/player/rewriter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/rewriter.dart';

const _masterSample = '''
#EXTM3U
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Italian",DEFAULT=YES,LANGUAGE="ita",URI="https://upstream/playlist?type=audio&rendition=ita&token=t1"
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="Italian",LANGUAGE="ita",URI="https://upstream/playlist?type=subtitle&rendition=ita&token=t1"
#EXT-X-STREAM-INF:BANDWIDTH=1200000,RESOLUTION=854x480,AUDIO="audio",SUBTITLES="subs"
https://upstream/playlist?type=video&rendition=480p&token=t1
#EXT-X-STREAM-INF:BANDWIDTH=2150000,RESOLUTION=1280x720,AUDIO="audio",SUBTITLES="subs"
https://upstream/playlist?type=video&rendition=720p&token=t1
''';

void main() {
  group('rewriteMaster', () {
    test('replaces video renditions with proxy paths labelled by ?rendition= param', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out, contains('/stream/sid/video/480p.m3u8'));
      expect(out, contains('/stream/sid/video/720p.m3u8'));
      expect(out, isNot(contains('upstream')));
    });

    test('replaces audio MEDIA URIs with proxy paths labelled by language', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out, contains('/stream/sid/audio/ita.m3u8'));
    });

    test('strips SUBTITLES MEDIA tags entirely', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out, isNot(contains('TYPE=SUBTITLES')));
      // And STREAM-INF must not reference the now-missing subtitle group.
      expect(out, isNot(contains('SUBTITLES="subs"')));
    });

    test('preserves STREAM-INF attributes (bandwidth, resolution)', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out, contains('BANDWIDTH=1200000'));
      expect(out, contains('RESOLUTION=854x480'));
    });

    test('falls back to sha1[:8] label when no ?rendition= query param', () {
      const sample = '''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=1000000,RESOLUTION=640x360
https://upstream/some/opaque/path/playlist.m3u8
''';
      final out = Rewriter.rewriteMaster(sample, basePath: '/stream/sid');
      // sha1 of the URL truncated to 8 hex chars.
      final pattern = RegExp(r'/stream/sid/video/[0-9a-f]{8}\.m3u8');
      expect(pattern.hasMatch(out), isTrue, reason: 'output: $out');
    });
  });
}
