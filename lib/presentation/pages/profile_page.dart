// lib/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../widgets/eyebrow.dart';
import '../widgets/primary_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Profilo'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Eyebrow('Account'),
                const SizedBox(height: 16),
                Text('Username',
                    style: StreamloadTypography.mono(fontSize: 11)),
                Text(user?.username ?? '—',
                    style: StreamloadTypography.body(fontSize: 18)),
                const SizedBox(height: 16),
                Text('Email',
                    style: StreamloadTypography.mono(fontSize: 11)),
                Text(user?.email ?? '—',
                    style: StreamloadTypography.body(fontSize: 14)),
                const SizedBox(height: 16),
                Text('Ruolo',
                    style: StreamloadTypography.mono(fontSize: 11)),
                Text(user?.role ?? '—',
                    style: StreamloadTypography.body(
                      fontSize: 14,
                      color: user?.role == 'admin'
                          ? StreamloadColors.accent
                          : StreamloadColors.textSecondary,
                    )),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Esci',
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
