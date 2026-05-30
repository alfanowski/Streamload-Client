// lib/state/search_query_provider.dart
//
// Shared search query — the single source of truth for the Apple-Music-style
// search. The bottom-bar search field (which expands from the Cerca button)
// writes the live query here; the SearchPage body reads it to run the search.
// Keeping it in a provider lets the input live in the bottom navigation bar
// while the results render in the page body.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current (trimmed-by-the-reader) search query. Empty → show suggestions.
final searchQueryProvider = StateProvider<String>((ref) => '');
