import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feed_row.dart';

class AnnouncementsScreen extends StatefulWidget {
  final PieCrewUser user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _service = AnnouncementService();

  Color _priorityColor(AnnouncementPriority p) {
    switch (p) {
      case AnnouncementPriority.urgent:
        return PieCrewColors.pie;
      case AnnouncementPriority.important:
        return PieCrewColors.ember;
      case AnnouncementPriority.normal:
        return PieCrewColors.inkMuted;
    }
  }

  IconData _priorityIcon(Announcement a) {
    if (a.pinned) return Icons.push_pin;
    if (a.priority == AnnouncementPriority.urgent) return Icons.warning_amber_rounded;
    return Icons.campaign_outlined;
  }

  void _openComposer() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool pinned = false;
    bool requireAck = false;
    AnnouncementPriority priority = AnnouncementPriority.normal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PieCrewColors.crust,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                Text('New announcement', style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextField(controller: bodyCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Message')),
                const SizedBox(height: 16),
                Text('Priority',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SegmentedButton<AnnouncementPriority>(
                  segments: const [
                    ButtonSegment(value: AnnouncementPriority.normal, label: Text('Normal')),
                    ButtonSegment(value: AnnouncementPriority.important, label: Text('Important')),
                    ButtonSegment(value: AnnouncementPriority.urgent, label: Text('Urgent')),
                  ],
                  selected: {priority},
                  onSelectionChanged: (s) => setSheetState(() => priority = s.first),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pin to top'),
                  value: pinned,
                  onChanged: (v) => setSheetState(() => pinned = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require acknowledgment'),
                  subtitle: Text('Staff must confirm they\'ve read it before it\'s marked done',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  value: requireAck,
                  onChanged: (v) => setSheetState(() => requireAck = v),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    await _service.post(
                      locationId: widget.user.locationId,
                      authorId: widget.user.uid,
                      authorName: widget.user.displayName,
                      authorPhotoUrl: widget.user.photoUrl,
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                      pinned: pinned,
                      priority: priority.name,
                      requireAcknowledgment: requireAck,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Post announcement'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetail(Announcement a) {
    final hasAcked = a.acknowledgedBy.contains(widget.user.uid);
    final needsAck = a.requireAcknowledgment && !hasAcked;
    showModalBottomSheet(
      context: context,
      backgroundColor: PieCrewColors.crust,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (a.pinned) const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.push_pin, size: 16, color: PieCrewColors.pie),
                ),
                Expanded(child: Text(a.title, style: Theme.of(ctx).textTheme.headlineSmall)),
              ],
            ),
            const SizedBox(height: 4),
            Text('${a.authorName} · ${timeago.format(a.createdAt)}', style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 14),
            Text(a.body, style: Theme.of(ctx).textTheme.bodyLarge),
            if (widget.user.canPostAnnouncements && a.requireAcknowledgment) ...[
              const SizedBox(height: 14),
              Text('${a.acknowledgedBy.length} team member(s) have acknowledged this.',
                  style: Theme.of(ctx).textTheme.bodySmall),
            ],
            if (needsAck) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _service.acknowledge(a.id, widget.user.uid);
                    Navigator.pop(ctx);
                  },
                  child: const Text("I've read this"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Announcement>>(
        stream: _service.streamForLocation(widget.user.locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Text('No announcements yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
            );
          }

          // The one thing needing attention most: the newest item that still
          // requires this person's acknowledgment, surfaced as a banner
          // instead of buried in the list.
          Announcement? needsAttention;
          for (final a in items) {
            final needsAck = a.requireAcknowledgment && !a.acknowledgedBy.contains(widget.user.uid);
            if (needsAck) {
              needsAttention = a;
              break;
            }
          }

          return Column(
            children: [
              if (needsAttention != null)
                AttentionBanner(
                  icon: Icons.priority_high_rounded,
                  text: '"${needsAttention.title}" needs your acknowledgment',
                  onTap: () => _openDetail(needsAttention!),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
                  itemBuilder: (context, i) {
                    final a = items[i];
                    final isUnread = !a.readBy.contains(widget.user.uid);
                    if (isUnread) _service.acknowledge(a.id, widget.user.uid).then((_) {});

                    return FeedRow(
                      icon: _priorityIcon(a),
                      iconColor: _priorityColor(a.priority),
                      title: a.title,
                      timeLabel: timeago.format(a.createdAt),
                      preview: a.body.isEmpty ? a.authorName : a.body,
                      unread: isUnread,
                      onTap: () => _openDetail(a),
                    );
                  },
                ),
              ),
            ],
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
