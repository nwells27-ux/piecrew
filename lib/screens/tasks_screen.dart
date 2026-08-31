import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feed_row.dart';

class TasksScreen extends StatefulWidget {
  final PieCrewUser user;
  const TasksScreen({super.key, required this.user});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _service = TaskService();

  void _openComposer() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TaskRecurrence recurrence = TaskRecurrence.once;
    bool requireNote = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PieCrewColors.crust,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 18, right: 18, top: 18,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New task', style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: const InputDecoration(
                  labelText: 'Task', hintText: 'e.g. Clean walk-in cooler')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(
                  labelText: 'Instructions (optional)')),
                const SizedBox(height: 16),
                Text('Repeats', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SegmentedButton<TaskRecurrence>(
                  segments: const [
                    ButtonSegment(value: TaskRecurrence.once, label: Text('One-time')),
                    ButtonSegment(value: TaskRecurrence.daily, label: Text('Daily')),
                    ButtonSegment(value: TaskRecurrence.weekly, label: Text('Weekly')),
                  ],
                  selected: {recurrence},
                  onSelectionChanged: (s) => setSheetState(() => recurrence = s.first),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require a note to complete'),
                  subtitle: Text('Whoever completes it must write a short note as proof',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  value: requireNote,
                  onChanged: (v) => setSheetState(() => requireNote = v),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    await _service.create(
                      locationId: widget.user.locationId,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      recurrence: recurrence,
                      requireNote: requireNote,
                      createdBy: widget.user.uid,
                      createdByName: widget.user.displayName,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Create task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeTask(PieCrewTask task) {
    if (!task.requireNote) {
      _service.complete(task: task, uid: widget.user.uid, userName: widget.user.displayName);
      return;
    }
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PieCrewColors.crust,
        title: Text(task.title),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Note', hintText: 'What did you do / find?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (noteCtrl.text.trim().isEmpty) return;
              _service.complete(
                task: task, uid: widget.user.uid, userName: widget.user.displayName,
                note: noteCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Mark complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<PieCrewTask>>(
        stream: _service.streamForLocation(widget.user.locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
          }
          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return Center(
              child: Text('No tasks yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
            itemBuilder: (context, i) {
              final task = tasks[i];
              return StreamBuilder<TaskCompletion?>(
                stream: _service.streamCurrentCompletion(task),
                builder: (context, compSnap) {
                  final completion = compSnap.data;
                  final isDone = completion != null;
                  return FeedRow(
                    icon: isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    iconColor: isDone ? PieCrewColors.basil : PieCrewColors.inkMuted,
                    title: task.title,
                    timeLabel: task.recurrence.label,
                    preview: isDone
                        ? 'Done by ${completion.completedByName}${completion.note != null ? ' · "${completion.note}"' : ''}'
                        : (task.description ?? 'Tap Complete when done'),
                    trailingBadge: isDone
                        ? null
                        : OutlinedButton(
                            onPressed: () => _completeTask(task),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Complete', style: TextStyle(fontSize: 11)),
                          ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: widget.user.canPostAnnouncements
          ? FloatingActionButton(
              onPressed: _openComposer,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
