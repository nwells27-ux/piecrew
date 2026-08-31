import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'maintenance_screen.dart';
import 'coworkers_screen.dart';
import 'admin_screen.dart';

class MoreScreen extends StatelessWidget {
  final PieCrewUser user;
  const MoreScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        icon: Icons.build_outlined,
        title: 'Equipment Issues',
        subtitle: 'Report and track maintenance problems',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MaintenanceScreen(user: user)),
        ),
      ),
      (
        icon: Icons.people_outline,
        title: 'Coworkers',
        subtitle: 'See who\'s on the team at your location',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CoworkersScreen(user: user)),
        ),
      ),
      (
        icon: Icons.admin_panel_settings_outlined,
        title: 'Admin',
        subtitle: 'Invite team members, manager log',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminScreen(user: user)),
        ),
      ),
    ];

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
        itemBuilder: (context, i) {
          final t = tiles[i];
          return ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: PieCrewColors.pie.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: Icon(t.icon, size: 20, color: PieCrewColors.pie),
            ),
            title: Text(t.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(t.subtitle, style: Theme.of(context).textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right, color: PieCrewColors.inkFaint),
            onTap: t.onTap,
          );
        },
      ),
    );
  }
}
