// lib/domain/models/catalog_item_x.dart
//
// Extension on [CatalogItemResponse] that adds Drift-specific helpers.
// Kept in a separate file so the freezed generator does not process the drift
// imports alongside the @freezed annotation.

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/local/database.dart';
import 'catalog_item.dart';

extension CatalogItemResponseX on CatalogItemResponse {
  /// Converts this response to a Drift [CatalogItemsCompanion] for upserts.
  CatalogItemsCompanion toCompanion() {
    return CatalogItemsCompanion(
      tmdbId: Value(tmdbId),
      mediaType: Value(mediaType),
      title: Value(title),
      originalTitle: Value(originalTitle),
      year: Value(year),
      posterUrl: Value(posterUrl),
      backdropUrl: Value(backdropUrl),
      overview: Value(overview),
      rating: Value(rating),
      runtimeMinutes: Value(runtimeMinutes),
      seasonsCount: Value(seasonsCount),
      genresJson: Value(jsonEncode(genres)),
    );
  }
}
