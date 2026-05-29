import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/view_models/media_card_vm.dart';

void main() {
  group('MediaCardVm.fromSummary', () {
    test('maps a full summary', () {
      const s = MediaSummary(
        tmdbId: 550,
        mediaType: 'movie',
        title: 'Fight Club',
        year: 1999,
        posterUrl: 'https://x/p.jpg',
      );
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.tmdbId, 550);
      expect(vm.title, 'Fight Club');
      expect(vm.posterUrl, 'https://x/p.jpg');
      expect(vm.metaLine, '1999 · Film');
    });

    test('null year is omitted from the meta line', () {
      const s = MediaSummary(tmdbId: 1, mediaType: 'tv', title: 'Shōgun');
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.metaLine, 'Serie');
    });

    test('empty poster becomes null so the media fallback kicks in', () {
      const s =
          MediaSummary(tmdbId: 2, mediaType: 'movie', title: 'X', posterUrl: '');
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.posterUrl, isNull);
    });

    test('blank title falls back to a placeholder string', () {
      const s = MediaSummary(tmdbId: 3, mediaType: 'movie', title: '   ');
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.title, 'Senza titolo');
    });

    test('unknown media type contributes nothing to the meta line', () {
      const s =
          MediaSummary(tmdbId: 4, mediaType: 'other', title: 'Y', year: 2020);
      final vm = MediaCardVm.fromSummary(s);
      expect(vm.metaLine, '2020');
    });
  });

  group('MediaCardVm.buildMetaLine', () {
    test('joins non-empty parts with a middot and drops blanks', () {
      expect(MediaCardVm.buildMetaLine(['2024', '', 'Film', '   ']),
          '2024 · Film');
    });
  });
}
