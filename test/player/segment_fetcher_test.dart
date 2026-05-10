// test/player/segment_fetcher_test.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/player/cache/disk_cache.dart';
import 'package:streamload_client/player/cache/ram_buffer.dart';
import 'package:streamload_client/player/segment_fetcher.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  late Directory tmp;
  late DiskSegmentCache disk;
  late RamRingBuffer ram;
  late _DioMock dio;
  late SegmentFetcher fetcher;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('seg_fetch_');
    disk = DiskSegmentCache(directory: tmp.path, sizeLimitBytes: 10 * 1024 * 1024);
    ram = RamRingBuffer(capacity: 4);
    dio = _DioMock();
    fetcher = SegmentFetcher(ram: ram, disk: disk, dio: dio);
    registerFallbackValue(RequestOptions(path: ''));
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Uint8List body(int n) => Uint8List.fromList(List.filled(n, 0xAB));

  test('RAM hit — does not touch disk or dio', () async {
    ram.put('http://x/seg.ts|', body(64));
    final out = await fetcher.fetch('http://x/seg.ts', headers: const {});
    expect(out.length, 64);
    verifyZeroInteractions(dio);
  });

  test('disk hit — promotes to RAM', () async {
    await disk.put('http://x/seg.ts|', body(32));
    final out = await fetcher.fetch('http://x/seg.ts', headers: const {});
    expect(out.length, 32);
    expect(ram.get('http://x/seg.ts|'), isNotNull);
    verifyZeroInteractions(dio);
  });

  test('miss — fetches via dio, stores in RAM + disk', () async {
    when(() => dio.get<List<int>>(
          'http://x/seg.ts',
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<List<int>>(
          requestOptions: RequestOptions(path: 'http://x/seg.ts'),
          data: body(128),
          statusCode: 200,
        ));
    final out = await fetcher.fetch('http://x/seg.ts', headers: const {'Referer': 'r'});
    expect(out.length, 128);
    expect(ram.get('http://x/seg.ts|Referer=r'), isNotNull);
    expect(await disk.get('http://x/seg.ts|Referer=r'), isNotNull);
  });

  test('decryptor is applied when supplied (DRM path)', () async {
    when(() => dio.get<List<int>>(
          any(),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response<List<int>>(
          requestOptions: RequestOptions(path: 'http://x/seg.ts'),
          data: body(16),
          statusCode: 200,
        ));
    final out = await fetcher.fetch(
      'http://x/seg.ts',
      headers: const {},
      decryptor: (raw) => Uint8List.fromList(raw.map((b) => b ^ 0xFF).toList()),
    );
    expect(out.first, 0x54); // 0xAB ^ 0xFF
  });
}
