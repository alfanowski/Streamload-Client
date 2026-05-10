// test/player/cache/ram_buffer_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/cache/ram_buffer.dart';

Uint8List _b(int v) => Uint8List.fromList([v]);

void main() {
  test('put + get round-trip', () {
    final buf = RamRingBuffer(capacity: 3);
    buf.put('a', _b(1));
    expect(buf.get('a'), equals(_b(1)));
    expect(buf.get('missing'), isNull);
  });

  test('LRU eviction at capacity', () {
    final buf = RamRingBuffer(capacity: 2);
    buf.put('a', _b(1));
    buf.put('b', _b(2));
    buf.put('c', _b(3)); // evicts 'a' (least recent)
    expect(buf.get('a'), isNull);
    expect(buf.get('b'), equals(_b(2)));
    expect(buf.get('c'), equals(_b(3)));
  });

  test('get bumps recency', () {
    final buf = RamRingBuffer(capacity: 2);
    buf.put('a', _b(1));
    buf.put('b', _b(2));
    buf.get('a'); // 'a' is now most recent
    buf.put('c', _b(3)); // evicts 'b' instead of 'a'
    expect(buf.get('a'), equals(_b(1)));
    expect(buf.get('b'), isNull);
  });

  test('put on existing key updates value and bumps recency', () {
    final buf = RamRingBuffer(capacity: 2);
    buf.put('a', _b(1));
    buf.put('b', _b(2));
    buf.put('a', _b(99)); // overwrite + bump
    buf.put('c', _b(3));  // evicts 'b'
    expect(buf.get('a'), equals(_b(99)));
    expect(buf.get('b'), isNull);
  });

  test('capacity < 1 throws', () {
    expect(() => RamRingBuffer(capacity: 0), throwsArgumentError);
  });
}
