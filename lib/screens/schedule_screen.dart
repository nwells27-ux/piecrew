import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user_model.dart';
import '../models/shift_model.dart';
import '../models/schedule_photo_model.dart';
import '../services/shift_service.dart';
import '../services/schedule_photo_service.dart';
import '../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  final PieCrewUser user;
  const ScheduleScreen({super.key, required this.user});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _service = ShiftService();
  final _photoService = SchedulePhotoService();
  bool _uploading = false;

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(d);
  }

  Future<void> _pickAndUploadPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: PieCrewColors.crust,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await _photoService.upload(
        file: File(picked.path),
        locationId: widget.user.locationId,
        uploadedBy: widget.user.uid,
        uploadedByName: widget.user.displayName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not upload photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _viewPhotoFullScreen(SchedulePhoto photo) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(photo.imageUrl),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoSection(bool canManage) {
    return StreamBuilder<SchedulePhoto?>(
      stream: _photoService.streamLatestForLocation(widget.user.locationId),
      builder: (context, snapshot) {
        final photo = snapshot.data;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: BoxDecoration(
            color: PieCrewColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PieCrewColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photo != null)
                GestureDetector(
                  onTap: () => _viewPhotoFullScreen(photo),
                  child: Image.network(
                    photo.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator(color: PieCrewColors.pie)),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  child: Text(
                    'No schedule photo yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                child: Row(
                  children: [
                    if (photo != null)
                      Expanded(
                        child: Text(
                          'Posted by ${photo.uploadedByName} · ${timeago.format(photo.uploadedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    else
                      const Spacer(),
                    if (canManage)
                      TextButton.icon(
                        onPressed: _uploading ? null : _pickAndUploadPhoto,
                        icon: _uploading
                            ? const SizedBox(
                                height: 14, width: 14,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.add_a_photo_outlined, size: 16),
                        label: Text(photo == null ? 'Add photo' : 'Update'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openComposer() {
    final nameCtrl = TextEditingController();
    final positionCtrl = TextEditingController();
    DateTime date = DateTime.now();
    TimeOfDay start = const TimeOfDay(hour: 16, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 22, minute: 0);

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
                Text('New shift', style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Team member')),
                const SizedBox(height: 12),
                TextField(controller: positionCtrl, decoration: const InputDecoration(labelText: 'Position (optional)')),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(date)),
                  trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                    );
                    if (picked != null) setSheetState(() => date = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start time'),
                  subtitle: Text(formatTimeOfDay(start)),
                  trailing: const Icon(Icons.schedule_outlined, size: 18),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: start);
                    if (picked != null) setSheetState(() => start = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End time'),
                  subtitle: Text(formatTimeOfDay(end)),
                  trailing: const Icon(Icons.schedule_outlined, size: 18),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: end);
                    if (picked != null) setSheetState(() => end = picked);
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await _service.create(
                      locationId: widget.user.locationId,
                      employeeName: nameCtrl.text.trim(),
                      date: date,
                      startMinutes: start.hour * 60 + start.minute,
                      endMinutes: end.hour * 60 + end.minute,
                      position: positionCtrl.text.trim().isEmpty ? null : positionCtrl.text.trim(),
                      createdBy: widget.user.uid,
                      createdByName: widget.user.displayName,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add shift'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = widget.user.canPostAnnouncements;
    return Scaffold(
      body: StreamBuilder<List<Shift>>(
        stream: _service.streamForLocation(widget.user.locationId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
          }
          final shifts = snapshot.data!;

          final groups = <String, List<Shift>>{};
          for (final s in shifts) {
            final key = DateFormat('yyyy-MM-dd').format(s.date);
            groups.putIfAbsent(key, () => []).add(s);
          }
          final sortedKeys = groups.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _photoSection(canManage),
              if (shifts.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text('No shifts scheduled yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
                  ),
                )
              else
                ...sortedKeys.map((key) {
                  final dayShifts = groups[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text(
                          _dayLabel(dayShifts.first.date),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w800, color: PieCrewColors.inkMuted, letterSpacing: 0.3),
                        ),
                      ),
                      ...dayShifts.map((s) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                      color: PieCrewColors.pie.withValues(alpha: 0.14), shape: BoxShape.circle),
                                  child: const Icon(Icons.person_outline, size: 20, color: PieCrewColors.pie),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.employeeName, style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${formatTimeOfDay(s.startTime)} – ${formatTimeOfDay(s.endTime)}'
                                        '${s.position != null ? ' · ${s.position}' : ''}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (canManage)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: PieCrewColors.inkFaint),
                                    onPressed: () => _service.delete(s.id),
                                    tooltip: 'Remove shift',
                                  ),
                              ],
                            ),
                          )),
                    ],
                  );
                }),
            ],
          );
        },
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: _openComposer,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
