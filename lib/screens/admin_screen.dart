import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'invite_staff_screen.dart';
import 'manager_log_screen.dart';

class AdminScreen extends StatelessWidget {
  final PieCrewUser user;
  const AdminScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (!user.canPostAnnouncements) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Center(
          child: Text('Only owners and managers can access admin tools.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
        ),
      );
    }

    final tiles = [
      (
        icon: Icons.person_add_alt_1_outlined,
        title: 'Invite Team Member',
        subtitle: 'Add a new account for your location',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InviteStaffScreen(currentUser: user)),
        ),
      ),
      (
        icon: Icons.assignment_outlined,
        title: 'Manager Log',
        subtitle: "See and add end-of-shift notes",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ManagerLogScreen(user: user)),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
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
