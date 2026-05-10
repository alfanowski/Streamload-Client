// lib/presentation/pages/watch_placeholder_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchPlaceholderPage extends ConsumerWidget {
  const WatchPlaceholderPage({
    super.key,
    required this.tmdbId,
    required this.mediaType,
    this.season,
    this.episode,
  });

  final int tmdbId;
  final String mediaType;
  final int? season;
  final int? episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riproduzione')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Player coming in sub-plan 6b.\n'
            'tmdb_id=$tmdbId · media_type=$mediaType'
            '${season != null ? "\nS$season E$episode" : ""}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
