import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user_model.dart';
import '../models/maintenance_model.dart';
import '../services/maintenance_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feed_row.dart';

class MaintenanceScreen extends StatefulWidget {
  final PieCrewUser user;
  const MaintenanceScreen({super.key, required this.user});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final _service = MaintenanceService();

  Color _statusColor(IssueStatus s) {
    switch (s) {
      case IssueStatus.reported:
        return PieCrewColors.pie;
      case IssueStatus.reviewing:
      case IssueStatus.vendorContacted:
      case IssueStatus.repairScheduled:
        return PieCrewColors.ember;
      case IssueStatus.resolved:
        return PieCrewColors.basil;
    }
  }

  void _openReportForm() {
    final equipmentCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    IssuePriority priority = IssuePriority.normal;

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
                Text('Report an issue', style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(controller: equipmentCtrl, decoration: const InputDecoration(
                  labelText: 'Equipment', hintText: 'e.g. Walk-in cooler')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(
                  labelText: "What's wrong?", hintText: 'e.g. Running at 48°F')),
                const SizedBox(height: 16),
                Text('Priority', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SegmentedButton<IssuePriority>(
                  segments: const [
                    ButtonSegment(value: IssuePriority.normal, label: Text('Normal')),
                    ButtonSegment(value: IssuePriority.urgent, label: Text('Urgent')),
                  ],
                  selected: {priority},
                  onSelectionChanged: (s) => setSheetState(() => priority = s.first),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (equipmentCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
                    await _service.report(
                      locationId: widget.user.locationId,
                      equipmentName: equipmentCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      priority: priority,
                      reportedBy: widget.user.uid,
                      reportedByName: widget.user.displayName,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Submit report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStatusPicker(MaintenanceIssue issue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PieCrewColors.crust,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: IssueStatus.values.map((s) {
            return ListTile(
              leading: Icon(Icons.circle, size: 12, color: _statusColor(s)),
              title: Text(s.label),
              trailing: issue.status == s ? const Icon(Icons.check, color: PieCrewColors.pie) : null,
              onTap: () {
                _service.updateStatus(issueId: issue.id, status: s, updatedByName: widget.user.displayName);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<MaintenanceIssue>>(
        stream: _service.streamForLocation(widget.user.locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
          }
          final issues = snapshot.data!;
          if (issues.isEmpty) {
            return Center(
              child: Text('No equipment issues reported.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
            );
          }
          final canManage = widget.user.canPostAnnouncements;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: issues.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
            itemBuilder: (context, i) {
              final issue = issues[i];
              final isResolved = issue.status == IssueStatus.resolved;
              return FeedRow(
                icon: isResolved ? Icons.check_circle : Icons.build_outlined,
                iconColor: _statusColor(issue.status),
                title: issue.equipmentName,
                timeLabel: timeago.format(issue.reportedAt),
                preview: '${issue.description}\n${issue.reportedByName}',
                trailingBadge: GestureDetector(
                  onTap: canManage ? () => _openStatusPicker(issue) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(issue.status).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(issue.status.label,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _statusColor(issue.status))),
                        if (canManage) ...[
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down, size: 14, color: _statusColor(issue.status)),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openReportForm,
        tooltip: 'Report an issue',
        child: const Icon(Icons.add_alert_outlined),
      ),
    );
  }
}
