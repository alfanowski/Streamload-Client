// lib/state/continue_watching_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/continue_watching_item.dart';
import 'api_client_provider.dart';

final continueWatchingProvider =
    FutureProvider<List<ContinueWatchingItem>>((ref) async {
  final api = await ref.watch(progressApiProvider.future);
  final raw = await api.continueWatching();
  final items = (raw['items'] as List).cast<Map<String, dynamic>>();
  return items.map(ContinueWatchingItem.fromJson).toList();
});
