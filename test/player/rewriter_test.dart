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
      expect(out.body, contains('/stream/sid/video/480p.m3u8'));
      expect(out.body, contains('/stream/sid/video/720p.m3u8'));
      expect(out.body, isNot(contains('upstream')));
    });

    test('replaces audio MEDIA URIs with proxy paths labelled by language', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out.body, contains('/stream/sid/audio/ita.m3u8'));
    });

    test('strips SUBTITLES MEDIA tags entirely', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out.body, isNot(contains('TYPE=SUBTITLES')));
      // And STREAM-INF must not reference the now-missing subtitle group.
      expect(out.body, isNot(contains('SUBTITLES="subs"')));
    });

    test('preserves STREAM-INF attributes (bandwidth, resolution)', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out.body, contains('BANDWIDTH=1200000'));
      expect(out.body, contains('RESOLUTION=854x480'));
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
      expect(pattern.hasMatch(out.body), isTrue, reason: 'output: ${out.body}');
    });

    test('renditionUrls maps label to original upstream URL', () {
      final out = Rewriter.rewriteMaster(_masterSample, basePath: '/stream/sid');
      expect(out.renditionUrls['480p'],
          'https://upstream/playlist?type=video&rendition=480p&token=t1');
      expect(out.renditionUrls['720p'],
          'https://upstream/playlist?type=video&rendition=720p&token=t1');
    });
  });

  group('rewriteMedia', () {
    const mediaSample = '''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXTINF:5.5,
https://upstream/seg-001.ts
#EXTINF:5.5,
https://upstream/seg-002.ts
#EXT-X-ENDLIST
''';

    test('replaces segment URLs with /seg/{rendition}/{n}.ts', () {
      final out = Rewriter.rewriteMedia(mediaSample,
          rendition: '720p', basePath: '/stream/sid');
      expect(out.body, contains('/stream/sid/seg/720p/0.ts'));
      expect(out.body, contains('/stream/sid/seg/720p/1.ts'));
      expect(out.body, isNot(contains('upstream')));
    });

    test('preserves EXTINF durations + EXT-X-ENDLIST', () {
      final out = Rewriter.rewriteMedia(mediaSample,
          rendition: '720p', basePath: '/stream/sid');
      expect(out.body, contains('#EXTINF:5.5'));
      expect(out.body, contains('#EXT-X-ENDLIST'));
    });

    test('rewrites EXT-X-KEY URI to local key proxy', () {
      const encrypted = '''
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXT-X-KEY:METHOD=AES-128,URI="https://upstream-keys/abc.key",IV=0xdeadbeef
#EXTINF:5.5,
https://upstream/seg-001.ts
#EXT-X-ENDLIST
''';
      final out = Rewriter.rewriteMedia(encrypted,
          rendition: '480p', basePath: '/stream/sid');
      expect(out.body, contains('URI="/stream/sid/key/480p"'));
      // IV preserved (player still needs it).
      expect(out.body, contains('IV=0xdeadbeef'));
      // Original key host gone.
      expect(out.body, isNot(contains('upstream-keys')));
    });

    test('returns key URL alongside body for AES-128 streams', () {
      const encrypted = '''
#EXTM3U
#EXT-X-KEY:METHOD=AES-128,URI="https://upstream-keys/abc.key",IV=0xdead
#EXTINF:5.5,
https://upstream/seg-001.ts
#EXT-X-ENDLIST
''';
      final out = Rewriter.rewriteMedia(encrypted,
          rendition: '480p', basePath: '/x');
      expect(out.keyUrl, 'https://upstream-keys/abc.key');
    });

    test('keyUrl is null for unencrypted streams', () {
      final out = Rewriter.rewriteMedia(mediaSample,
          rendition: '720p', basePath: '/stream/sid');
      expect(out.keyUrl, isNull);
    });

    test('segmentUrls contains original upstream segment URLs in order', () {
      final out = Rewriter.rewriteMedia(mediaSample,
          rendition: '720p', basePath: '/stream/sid');
      expect(out.segmentUrls, hasLength(2));
      expect(out.segmentUrls[0], 'https://upstream/seg-001.ts');
      expect(out.segmentUrls[1], 'https://upstream/seg-002.ts');
    });
  });
}
