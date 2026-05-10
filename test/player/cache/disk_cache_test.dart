// test/player/cache/disk_cache_test.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/cache/disk_cache.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('disk_cache_test_');
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Uint8List bytes(int n) => Uint8List.fromList(List.filled(n, 0x42));

  test('put + get round-trip', () async {
    final c = DiskSegmentCache(directory: tmp.path, sizeLimitBytes: 1024 * 1024);
    await c.put('k1', bytes(128));
    final got = await c.get('k1');
    expect(got, isNotNull);
    expect(got!.length, 128);
  });

  test('get returns null for missing key', () async {
    final c = DiskSegmentCache(directory: tmp.path, sizeLimitBytes: 1024);
    expect(await c.get('missing'), isNull);
  });

  test('LRU eviction when total size exceeds the limit', () async {
    // Limit: 300 bytes. Insert three 200-byte entries → first must be evicted.
    final c = DiskSegmentCache(directory: tmp.path, sizeLimitBytes: 300);
    await c.put('a', bytes(200));
    await Future.delayed(const Duration(milliseconds: 5));
    await c.put('b', bytes(200));
    await Future.delayed(const Duration(milliseconds: 5));
    await c.put('c', bytes(200));
    expect(await c.get('a'), isNull, reason: 'a should be evicted');
    expect(await c.get('c'), isNotNull);
  });

  test('get bumps recency — preserves entry on next eviction', () async {
    // Limit: 500 bytes — holds 2×200-byte entries (400 ≤ 500) without
    // eviction, but not 3 (600 > 500 → evict 1 LRU entry).
    final c = DiskSegmentCache(directory: tmp.path, sizeLimitBytes: 500);
    await c.put('a', bytes(200));
    await Future.delayed(const Duration(milliseconds: 5));
    await c.put('b', bytes(200));
    await Future.delayed(const Duration(milliseconds: 5));
    await c.get('a'); // bump 'a' to most recent
    await Future.delayed(const Duration(milliseconds: 5));
    await c.put('c', bytes(200)); // evicts 'b' (LRU) instead of 'a'
    expect(await c.get('a'), isNotNull);
    expect(await c.get('b'), isNull);
  });
}
