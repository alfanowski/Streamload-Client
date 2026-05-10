// lib/player/segment_fetcher.dart
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'cache/disk_cache.dart';
import 'cache/ram_buffer.dart';

typedef SegmentDecryptor = Uint8List Function(Uint8List raw);

class SegmentFetcher {
  SegmentFetcher({
    required this.ram,
    required this.disk,
    required this.dio,
  });

  final RamRingBuffer ram;
  final DiskSegmentCache disk;
  final Dio dio;

  /// Cache key includes headers so two sessions with different auth don't
  /// share encrypted bytes. Headers are sorted+joined to produce a stable key.
  static String _cacheKey(String url, Map<String, String> headers) {
    final entries = headers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final headerPart = entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$url|$headerPart';
  }

  Future<Uint8List> fetch(
    String url, {
    required Map<String, String> headers,
    SegmentDecryptor? decryptor,
  }) async {
    final key = _cacheKey(url, headers);

    final hot = ram.get(key);
    if (hot != null) return hot;

    final warm = await disk.get(key);
    if (warm != null) {
      ram.put(key, warm);
      return warm;
    }

    final resp = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: headers,
      ),
    );
    final raw = Uint8List.fromList(resp.data ?? const []);
    final out = decryptor == null ? raw : decryptor(raw);
    ram.put(key, out);
    await disk.put(key, out);
    return out;
  }
}
