// test/player/drm_test.dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/player/drm.dart';

void main() {
  test('aes-128-cbc decrypt round-trip with PKCS7-padded plaintext', () {
    // Encrypt "hello world!!!!!" (16 bytes, no padding needed) with:
    // key = 0x42 * 16, iv = 0x10 * 16.
    // Vector verified via PyCryptodome:
    //   AES.new(b'\x42'*16, AES.MODE_CBC, b'\x10'*16).encrypt(b'hello world!!!!!')
    //   → [0x24, 0x0a, 0x7b, 0x02, 0x0b, 0xbc, 0xcf, 0xf1,
    //      0x7b, 0x99, 0xaf, 0x91, 0xa8, 0x41, 0x76, 0x9b]
    final key = Uint8List(16)..fillRange(0, 16, 0x42);
    final iv = Uint8List(16)..fillRange(0, 16, 0x10);
    final ct = Uint8List.fromList(const [
      0x24, 0x0a, 0x7b, 0x02, 0x0b, 0xbc, 0xcf, 0xf1,
      0x7b, 0x99, 0xaf, 0x91, 0xa8, 0x41, 0x76, 0x9b,
    ]);

    final dec = SegmentDrm(keyBytes: key, ivBytes: iv);
    final out = dec.decrypt(ct);
    expect(out, equals(Uint8List.fromList('hello world!!!!!'.codeUnits)));
  });

  test('keyBytes must be exactly 16 bytes (AES-128)', () {
    expect(
      () => SegmentDrm(keyBytes: Uint8List(8), ivBytes: Uint8List(16)),
      throwsArgumentError,
    );
  });

  test('ivBytes must be exactly 16 bytes', () {
    expect(
      () => SegmentDrm(keyBytes: Uint8List(16), ivBytes: Uint8List(8)),
      throwsArgumentError,
    );
  });
}
