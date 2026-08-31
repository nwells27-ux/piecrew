import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user_model.dart';
import '../models/manager_log_model.dart';
import '../services/manager_log_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feed_row.dart';

class ManagerLogScreen extends StatefulWidget {
  final PieCrewUser user;
  const ManagerLogScreen({super.key, required this.user});

  @override
  State<ManagerLogScreen> createState() => _ManagerLogScreenState();
}

class _ManagerLogScreenState extends State<ManagerLogScreen> {
  final _service = ManagerLogService();

  void _openComposer() {
    final salesCtrl = TextEditingController();
    final staffingCtrl = TextEditingController();
    final customerCtrl = TextEditingController();
    final equipmentCtrl = TextEditingController();
    final generalCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PieCrewColors.crust,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 18, right: 18, top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New log entry', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text("Leave anything blank that doesn't apply.", style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 16),
              TextField(controller: salesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Sales notes')),
              const SizedBox(height: 12),
              TextField(controller: staffingCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Staffing issues')),
              const SizedBox(height: 12),
              TextField(controller: customerCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Customer issues')),
              const SizedBox(height: 12),
              TextField(controller: equipmentCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Equipment issues')),
              const SizedBox(height: 12),
              TextField(controller: generalCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'General notes')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  String? clean(String s) => s.trim().isEmpty ? null : s.trim();
                  if ([salesCtrl, staffingCtrl, customerCtrl, equipmentCtrl, generalCtrl]
                      .every((c) => c.text.trim().isEmpty)) {
                    return;
                  }
                  await _service.post(
                    locationId: widget.user.locationId,
                    authorId: widget.user.uid,
                    authorName: widget.user.displayName,
                    salesNotes: clean(salesCtrl.text),
                    staffingNotes: clean(staffingCtrl.text),
                    customerNotes: clean(customerCtrl.text),
                    equipmentNotes: clean(equipmentCtrl.text),
                    generalNotes: clean(generalCtrl.text),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save log entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: PieCrewColors.inkMuted)),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  String _preview(ManagerLogEntry e) {
    if (e.isEmpty) return 'No notes.';
    final parts = [e.salesNotes, e.staffingNotes, e.customerNotes, e.equipmentNotes, e.generalNotes]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.join(' · ');
  }

  void _openDetail(ManagerLogEntry e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PieCrewColors.crust,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.authorName, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(timeago.format(e.createdAt), style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 16),
              if (e.isEmpty)
                Text('No notes.', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted))
              else ...[
                _section(ctx, 'Sales', e.salesNotes),
                _section(ctx, 'Staffing', e.staffingNotes),
                _section(ctx, 'Customers', e.customerNotes),
                _section(ctx, 'Equipment', e.equipmentNotes),
                _section(ctx, 'General', e.generalNotes),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager log')),
      body: StreamBuilder<List<ManagerLogEntry>>(
        stream: _service.streamForLocation(widget.user.locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
          }
          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return Center(
              child: Text('No log entries yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
            itemBuilder: (context, i) {
              final e = entries[i];
              return FeedRow(
                icon: Icons.assignment_outlined,
                iconColor: PieCrewColors.inkMuted,
                title: e.authorName,
                timeLabel: timeago.format(e.createdAt),
                preview: _preview(e),
                onTap: () => _openDetail(e),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openComposer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
