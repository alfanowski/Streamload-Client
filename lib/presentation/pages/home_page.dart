// lib/presentation/pages/home_page.dart
//
// PLACEHOLDER. Real home (rows of poster cards from collections) is sub-plan #6.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final username = switch (auth) {
      AuthAuthenticated(:final user) => user.username,
      _ => 'guest',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Streamload',
          style: StreamloadTypography.display(fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: 'Impostazioni',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            tooltip: 'Profilo',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Eyebrow('Benvenuto'),
            const SizedBox(height: 8),
            Text(
              username,
              style: StreamloadTypography.display(fontSize: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Il catalogo arriva nei prossimi rilasci.',
              style: StreamloadTypography.body(
                fontSize: 14,
                color: StreamloadColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
