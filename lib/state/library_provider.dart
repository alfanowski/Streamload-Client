// lib/state/library_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/library_page_data.dart';
import 'api_client_provider.dart';

class LibraryQuery {
  const LibraryQuery({
    required this.mediaType,
    this.page = 1,
    this.perPage = 24,
  });

  final String mediaType;
  final int page;
  final int perPage;

  @override
  bool operator ==(Object other) =>
      other is LibraryQuery &&
      other.mediaType == mediaType &&
      other.page == page &&
      other.perPage == perPage;

  @override
  int get hashCode => Object.hash(mediaType, page, perPage);
}

final libraryProvider =
    FutureProvider.family<LibraryPageData, LibraryQuery>((ref, q) async {
  final api = await ref.watch(libraryApiProvider.future);
  final raw = await api.page(
    mediaType: q.mediaType,
    page: q.page,
    perPage: q.perPage,
  );
  return LibraryPageData.fromJson(raw);
});
