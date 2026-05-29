// lib/presentation/widgets/primitives/async_state_view.dart
//
// The ONLY way a screen renders a Riverpod AsyncValue. Guarantees every
// data-driven surface handles all four states: loading, empty, error
// (with retry), data. No screen calls AsyncValue.when by hand — that's how
// "empty holes" and crash-on-error slipped in before.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/tokens.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.value,
    required this.loading,
    required this.onRetry,
    required this.data,
    this.isEmpty,
    this.empty,
  });

  final AsyncValue<T> value;
  final Widget loading;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  /// Optional predicate: when it returns true the [empty] widget is shown
  /// instead of [data]. If null, data is always rendered.
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading,
      error: (_, __) => StreamloadErrorState(onRetry: onRetry),
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return empty ??
              const StreamloadEmptyState(message: 'Niente da mostrare');
        }
        return data(d);
      },
    );
  }
}

class StreamloadEmptyState extends StatelessWidget {
  const StreamloadEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.movie_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(StreamloadTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: StreamloadTokens.textMuted, size: 40),
            const SizedBox(height: StreamloadTokens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: StreamloadTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamloadErrorState extends StatelessWidget {
  const StreamloadErrorState({
    super.key,
    required this.onRetry,
    this.message = 'Qualcosa è andato storto',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(StreamloadTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: StreamloadTokens.critical, size: 40),
            const SizedBox(height: StreamloadTokens.space3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: StreamloadTokens.textSecondary),
            ),
            const SizedBox(height: StreamloadTokens.space4),
            TextButton(
              onPressed: onRetry,
              child: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
