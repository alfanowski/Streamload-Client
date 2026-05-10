// lib/state/search_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/media_summary.dart';
import 'api_client_provider.dart';

class SearchController extends StateNotifier<AsyncValue<List<MediaSummary>>> {
  SearchController(this._ref) : super(const AsyncData([]));

  final Ref _ref;
  Timer? _debounce;
  String _query = '';

  void setQuery(String q) {
    _query = q.trim();
    _debounce?.cancel();
    if (_query.isEmpty) {
      state = const AsyncData([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), _run);
  }

  Future<void> _run() async {
    final q = _query;
    state = const AsyncLoading();
    try {
      final api = await _ref.read(searchApiProvider.future);
      final raw = await api.run(q);
      // Backend SearchResponse returns { query, results: [...] }, not items.
      final items = (raw['results'] as List)
          .cast<Map<String, dynamic>>()
          .map(MediaSummary.fromJson)
          .toList();
      // Discard if a newer query took over.
      if (q != _query) return;
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, AsyncValue<List<MediaSummary>>>(
  (ref) => SearchController(ref),
);
