// lib/state/api_client_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/api_client.dart';
import '../data/remote/endpoints/admin_api.dart';
import '../data/remote/endpoints/auth_api.dart';
import '../data/remote/endpoints/catalog_api.dart';
import '../data/remote/endpoints/collections_api.dart';
import '../data/remote/endpoints/episodes_api.dart';
import '../data/remote/endpoints/events_api.dart';
import '../data/remote/endpoints/favorites_api.dart';
import '../data/remote/endpoints/intro_api.dart';
import '../data/remote/endpoints/library_api.dart';
import '../data/remote/endpoints/next_up_api.dart';
import '../data/remote/endpoints/progress_api.dart';
import '../data/remote/endpoints/search_api.dart';
import '../data/remote/endpoints/settings_api.dart';
import '../data/remote/endpoints/watchlist_api.dart';

/// Async — created once at app boot. Override in tests with a fake ApiClient.
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  return ApiClient.create();
});

/// Convenience family of typed API providers, each pulling from apiClientProvider.
final authApiProvider = FutureProvider<AuthApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return AuthApi(c);
});

final catalogApiProvider = FutureProvider<CatalogApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return CatalogApi(c);
});

final collectionsApiProvider = FutureProvider<CollectionsApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return CollectionsApi(c);
});

final episodesApiProvider = FutureProvider<EpisodesApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return EpisodesApi(c);
});

final searchApiProvider = FutureProvider<SearchApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return SearchApi(c);
});

final introApiProvider = FutureProvider<IntroApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return IntroApi(c);
});

final nextUpApiProvider = FutureProvider<NextUpApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return NextUpApi(c);
});

final progressApiProvider = FutureProvider<ProgressApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return ProgressApi(c);
});

final favoritesApiProvider = FutureProvider<FavoritesApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return FavoritesApi(c);
});

final watchlistApiProvider = FutureProvider<WatchlistApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return WatchlistApi(c);
});

final libraryApiProvider = FutureProvider<LibraryApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return LibraryApi(c);
});

final settingsApiProvider = FutureProvider<SettingsApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return SettingsApi(c);
});

final eventsApiProvider = FutureProvider<EventsApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return EventsApi(c);
});

final adminApiProvider = FutureProvider<AdminApi>((ref) async {
  final c = await ref.watch(apiClientProvider.future);
  return AdminApi(c);
});
