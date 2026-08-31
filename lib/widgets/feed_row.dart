import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A single scannable row for PieCrew's feeds: an icon in a tinted circle,
/// a bold title with a timestamp trailing it, and a muted preview line
/// underneath. Rows sit in a continuous list with a hairline divider
/// between them, rather than boxed individually — the "keep it fast to
/// scan" pattern that fits a crew checking updates between orders.
class FeedRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String timeLabel;
  final String preview;
  final Widget? trailingBadge;
  final VoidCallback? onTap;
  final bool unread;

  const FeedRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.timeLabel,
    required this.preview,
    this.trailingBadge,
    this.onTap,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.14), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(timeLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: PieCrewColors.inkFaint, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: PieCrewColors.inkMuted, height: 1.35),
                  ),
                ],
              ),
            ),
            if (trailingBadge != null) ...[
              const SizedBox(width: 8),
              trailingBadge!,
            ],
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: PieCrewColors.pie, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A slim callout banner for the one thing that most needs attention right
/// now — mirrors the "someone needs shift coverage" strip pattern: a short
/// icon-led line pinned above the feed, not another card competing for
/// attention.
class AttentionBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const AttentionBanner({super.key, required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: PieCrewColors.pieTint,
        child: Row(
          children: [
            Icon(icon, size: 18, color: PieCrewColors.pie),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: PieCrewColors.pieDark, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
