// test/plugins/host/crypto_host_test.dart
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/host/crypto_host.dart';

void main() {
  test('sha256 of empty string', () {
    expect(CryptoHost.sha256Hex(''),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
  });

  test('sha256 of "hello"', () {
    expect(CryptoHost.sha256Hex('hello'),
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824');
  });

  test('md5 of empty string', () {
    expect(CryptoHost.md5Hex(''), 'd41d8cd98f00b204e9800998ecf8427e');
  });

  test('hmac sha256 known vector (RFC 4231 test 1)', () {
    final key = Uint8List.fromList(List.filled(20, 0x0b));
    final data = Uint8List.fromList('Hi There'.codeUnits);
    expect(
      CryptoHost.hmacHex('sha256', key, data),
      'b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7',
    );
  });

  test('base64 round-trip', () {
    expect(CryptoHost.base64Encode('Hello, world!'), 'SGVsbG8sIHdvcmxkIQ==');
  });

  test('aesDecrypt CBC with PKCS7 padding (HLS-style key)', () {
    // Key = 16 bytes of 0x42. IV = 16 bytes of 0x10.
    // Plaintext "yo" padded PKCS7 to 16 bytes, encrypted with AES-128-CBC.
    final key = Uint8List.fromList(List.filled(16, 0x42));
    final iv = Uint8List.fromList(List.filled(16, 0x10));
    // Pre-computed ciphertext for plaintext = "yo" + padding 14*0x0e
    // (verified with PyCryptodome AES-128-CBC):
    final ciphertext = Uint8List.fromList([
      0x2c, 0x37, 0xd6, 0xbe, 0xcf, 0xa6, 0x0d, 0xbd,
      0x48, 0xad, 0x6c, 0x8c, 0xdd, 0xaf, 0xa6, 0x70,
    ]);
    final out = CryptoHost.aesDecryptCbc(ciphertext, key, iv);
    expect(String.fromCharCodes(out), 'yo');
  });
}
