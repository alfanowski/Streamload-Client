// lib/player/cache/disk_cache.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Filesystem-backed LRU cache. Each entry is one file under `directory/`,
/// named by sha1 of the key. Access time is tracked via a sidecar `.lru`
/// file (written on every [get] + [put]) to work around macOS
/// `setLastAccessed` being a no-op on APFS. Eviction sorts files by
/// recorded atime ascending and removes oldest until total size is below
/// the limit.
class DiskSegmentCache {
  DiskSegmentCache({
    required this.directory,
    required this.sizeLimitBytes,
  }) {
    Directory(directory).createSync(recursive: true);
  }

  final String directory;
  final int sizeLimitBytes;

  String _pathFor(String key) {
    final h = sha1.convert(utf8.encode(key)).toString();
    return '$directory/$h.bin';
  }

  String _lruPathFor(String key) => '${_pathFor(key)}.lru';

  Future<void> _touchLru(String key) async {
    final lruFile = File(_lruPathFor(key));
    await lruFile.writeAsString(DateTime.now().microsecondsSinceEpoch.toString());
  }

  Future<DateTime> _readLru(String binPath) async {
    final lruFile = File('$binPath.lru');
    if (await lruFile.exists()) {
      try {
        final micros = int.parse((await lruFile.readAsString()).trim());
        return DateTime.fromMicrosecondsSinceEpoch(micros);
      } catch (_) {}
    }
    // Fallback to file modification time.
    return (await File(binPath).stat()).modified;
  }

  Future<Uint8List?> get(String key) async {
    final f = File(_pathFor(key));
    if (!await f.exists()) return null;
    // Bump atime so LRU sees this as recent.
    await _touchLru(key);
    try {
      await f.setLastAccessed(DateTime.now());
    } catch (_) {/* some FSes don't support; ignore */}
    return f.readAsBytes();
  }

  Future<void> put(String key, Uint8List value) async {
    final f = File(_pathFor(key));
    await f.writeAsBytes(value, flush: true);
    await _touchLru(key);
    await _evictIfNeeded();
  }

  Future<void> _evictIfNeeded() async {
    final dir = Directory(directory);
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.bin'))
        .cast<File>()
        .toList();

    int total = 0;
    final entries = <_Entry>[];
    for (final f in files) {
      final st = await f.stat();
      total += st.size;
      final accessed = await _readLru(f.path);
      entries.add(_Entry(f, accessed, st.size));
    }
    if (total <= sizeLimitBytes) return;

    entries.sort((a, b) => a.accessed.compareTo(b.accessed));
    for (final e in entries) {
      if (total <= sizeLimitBytes) return;
      await e.file.delete();
      // Also clean up sidecar.
      final lru = File('${e.file.path}.lru');
      if (await lru.exists()) await lru.delete();
      total -= e.size;
    }
  }
}

class _Entry {
  _Entry(this.file, this.accessed, this.size);
  final File file;
  final DateTime accessed;
  final int size;
}
