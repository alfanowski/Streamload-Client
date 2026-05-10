// lib/player/drm.dart
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// AES-128-CBC segment decryptor for HLS streams that ship with
/// `#EXT-X-KEY:METHOD=AES-128`. The key is 16 bytes; the IV is either
/// declared on the EXT-X-KEY line or implied by segment number (left
/// to the caller to compute IV-per-segment if needed).
class SegmentDrm {
  SegmentDrm({required Uint8List keyBytes, required Uint8List ivBytes})
      : _key = keyBytes,
        _iv = ivBytes {
    if (keyBytes.length != 16) {
      throw ArgumentError.value(
          keyBytes.length, 'keyBytes', 'AES-128 requires a 16-byte key');
    }
    if (ivBytes.length != 16) {
      throw ArgumentError.value(
          ivBytes.length, 'ivBytes', 'AES requires a 16-byte IV');
    }
  }

  final Uint8List _key;
  final Uint8List _iv;

  Uint8List decrypt(Uint8List ciphertext) {
    final cbc = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(_key), _iv));
    final out = Uint8List(ciphertext.length);
    var offset = 0;
    while (offset < ciphertext.length) {
      offset += cbc.processBlock(ciphertext, offset, out, offset);
    }
    return out;
  }
}
