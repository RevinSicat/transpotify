import 'package:flutter/material.dart';

import '../../core/database/schedule/dao/schedule_dao.dart';
import '../theme/app_colors.dart';

class SegmentAccordion extends StatelessWidget {
  const SegmentAccordion({
    required this.segments,
    this.title = 'Route segments',
    this.initiallyExpanded = false,
    super.key,
  });

  final List<SegmentAverage> segments;
  final String title;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMinutes = segments.fold<double>(
      0,
      (total, segment) => total + segment.effectiveMinutes,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          segments.isEmpty
              ? 'No segments'
              : '${segments.length} ${segments.length == 1 ? 'segment' : 'segments'}'
                    ' · ${_formatDuration(totalMinutes.round())}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: segments.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No segments in this schedule yet.'),
                  ),
                ),
              ]
            : [
                for (var index = 0; index < segments.length; index++)
                  _SegmentRow(
                    segment: segments[index],
                    isLast: index == segments.length - 1,
                  ),
              ],
      ),
    );
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({required this.segment, required this.isLast});

  final SegmentAverage segment;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).colorScheme;
    final modeColor = AppColors.transportModeColor(
      segment.segment.transportMode,
    );
    final durationText = segment.averageMinutes == null
        ? 'Est. ${_formatDuration(segment.segment.estimatedDurationMinutes)}'
        : 'Avg. ${_formatDuration(segment.averageMinutes!.round())}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    AppColors.transportModeIcon(segment.segment.transportMode),
                    size: 17,
                    color: modeColor,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    margin: const EdgeInsets.only(top: 3),
                    color: colors.outlineVariant,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: isLast ? 16 : 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          segment.segment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _labelMode(segment.segment.transportMode),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: modeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    durationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _labelMode(String mode) {
    final normalized = mode.trim().toLowerCase();
    if (normalized.isEmpty) return 'Other';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}
