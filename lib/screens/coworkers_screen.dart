import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/coworkers_service.dart';
import '../theme/app_theme.dart';

class CoworkersScreen extends StatelessWidget {
  final PieCrewUser user;
  const CoworkersScreen({super.key, required this.user});

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return PieCrewColors.pie;
      case UserRole.manager:
        return PieCrewColors.ember;
      case UserRole.staff:
        return PieCrewColors.inkMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = CoworkersService();
    return Scaffold(
      appBar: AppBar(title: const Text('Coworkers')),
      body: StreamBuilder<List<PieCrewUser>>(
        stream: service.streamForLocation(user.locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
          }
          final coworkers = snapshot.data!;
          if (coworkers.isEmpty) {
            return Center(
              child: Text('No team members yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: coworkers.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
            itemBuilder: (context, i) {
              final c = coworkers[i];
              final isMe = c.uid == user.uid;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _roleColor(c.role).withValues(alpha: 0.14),
                      backgroundImage: c.photoUrl != null ? NetworkImage(c.photoUrl!) : null,
                      child: c.photoUrl == null
                          ? Text(
                              c.displayName.isNotEmpty ? c.displayName[0].toUpperCase() : '?',
                              style: TextStyle(color: _roleColor(c.role), fontWeight: FontWeight.w800),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c.displayName, style: Theme.of(context).textTheme.titleMedium),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Text('(you)',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PieCrewColors.inkFaint)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(c.email,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PieCrewColors.inkMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _roleColor(c.role).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c.role.label,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _roleColor(c.role)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
