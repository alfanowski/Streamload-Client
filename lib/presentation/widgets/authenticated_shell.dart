// lib/presentation/widgets/authenticated_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthenticatedShell extends StatelessWidget {
  const AuthenticatedShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    (path: '/home',    icon: Icons.home_outlined,           label: 'Home'),
    (path: '/library', icon: Icons.video_library_outlined,  label: 'Libreria'),
    (path: '/search',  icon: Icons.search,                  label: 'Cerca'),
    (path: '/profile', icon: Icons.person_outline,          label: 'Profilo'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final selected = _destinations.indexWhere((d) => loc.startsWith(d.path));
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selected < 0 ? 0 : selected,
            onDestinationSelected: (i) => context.go(_destinations[i].path),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
