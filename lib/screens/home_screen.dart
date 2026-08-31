import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'announcements_screen.dart';
import 'schedule_screen.dart';
import 'tasks_screen.dart';
import 'maintenance_screen.dart';
import 'chat_screen.dart';
import 'invite_staff_screen.dart';
import 'manager_log_screen.dart';

class HomeScreen extends StatefulWidget {
  final PieCrewUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Announcements', 'Schedule', 'Tasks', 'Maintenance', 'Team Chat'];

  @override
  Widget build(BuildContext context) {
    final screens = [
      AnnouncementsScreen(user: widget.user),
      ScheduleScreen(user: widget.user),
      TasksScreen(user: widget.user),
      MaintenanceScreen(user: widget.user),
      ChatScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (widget.user.canPostAnnouncements)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: 'Invite team member',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InviteStaffScreen(currentUser: widget.user),
                ),
              ),
            ),
          if (widget.user.canPostAnnouncements)
            IconButton(
              icon: const Icon(Icons.assignment_outlined),
              tooltip: 'Manager log',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerLogScreen(user: widget.user),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'News'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Issues'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        ],
      ),
    );
  }
}
