// lib/state/collections_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/collection_summary.dart';
import 'api_client_provider.dart';

final collectionsProvider = FutureProvider<List<CollectionSummary>>((ref) async {
  final api = await ref.watch(collectionsApiProvider.future);
  final raw = await api.list();
  return raw.map(CollectionSummary.fromJson).toList(growable: false);
});
