// lib/plugins/host/crypto_host.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as c;
import 'package:pointycastle/export.dart' as pc;

class CryptoHost {
  CryptoHost._();

  static String sha256Hex(String input) {
    return c.sha256.convert(utf8.encode(input)).toString();
  }

  static String md5Hex(String input) {
    return c.md5.convert(utf8.encode(input)).toString();
  }

  /// HMAC over arbitrary bytes. `algorithm` is "sha1" or "sha256".
  static String hmacHex(String algorithm, List<int> key, List<int> data) {
    final hash = switch (algorithm) {
      'sha1' => c.sha1,
      'sha256' => c.sha256,
      _ => throw ArgumentError.value(algorithm, 'algorithm', 'unsupported'),
    };
    return c.Hmac(hash, key).convert(data).toString();
  }

  static String base64Encode(String input) {
    return base64.encode(utf8.encode(input));
  }

  /// AES-128/192/256-CBC decrypt with PKCS#7 unpadding.
  /// Used for HLS clear-key segment decryption (matches the v2 backend's
  /// streaming/drm.py behaviour).
  static Uint8List aesDecryptCbc(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    final cipher = pc.PaddedBlockCipherImpl(
      pc.PKCS7Padding(),
      pc.CBCBlockCipher(pc.AESEngine()),
    );
    cipher.init(
      false,
      pc.PaddedBlockCipherParameters(
        pc.ParametersWithIV(pc.KeyParameter(key), iv),
        null,
      ),
    );
    return cipher.process(ciphertext);
  }
}
