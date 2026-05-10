// lib/player/cache/ram_buffer.dart
import 'dart:collection';
import 'dart:typed_data';

/// Simple in-memory LRU cache for hot segments. Per-session capacity
/// (typically 30 segments at ~6s each = ~3 minutes of buffer).
class RamRingBuffer {
  RamRingBuffer({required this.capacity}) {
    if (capacity < 1) {
      throw ArgumentError.value(capacity, 'capacity', 'must be >= 1');
    }
  }

  final int capacity;
  final LinkedHashMap<String, Uint8List> _store = LinkedHashMap();

  Uint8List? get(String key) {
    final v = _store.remove(key);
    if (v == null) return null;
    _store[key] = v; // re-insert at the end → most recent
    return v;
  }

  void put(String key, Uint8List value) {
    _store.remove(key); // ensure correct ordering even on overwrite
    _store[key] = value;
    while (_store.length > capacity) {
      _store.remove(_store.keys.first);
    }
  }

  int get length => _store.length;
}
