import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/utils/common_utilities.dart';
import '../common/widgets/schedule_card.dart';
import '../core/database/database.dart';
import '../core/database/schedule/dao/schedule_dao.dart';
import '../features/schedule/controllers/schedule_controller.dart';
import '../features/transit/controllers/active_transit_controller.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(schedulesProvider);
    final activeTransit = ref.watch(activeTransitProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedules')),
      body: schedules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ScheduleError(
          message: 'Could not load schedules: $error',
          onRetry: () => ref.invalidate(schedulesProvider),
        ),
        data: (items) {
          if (items.isEmpty) return const _ScheduleEmptyState();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ScheduleManagementCard(
                schedule: item,
                isCurrentCommute:
                    activeTransit.asData?.value?.log.scheduleId ==
                    item.schedule.id,
                onCommutePressed: () async {
                  final active = activeTransit.asData?.value;
                  if (active != null) {
                    if (active.log.scheduleId == item.schedule.id) {
                      context.go('/active');
                    } else {
                      _showMessage(
                        context,
                        'Finish or cancel the current commute first.',
                      );
                    }
                    return;
                  }
                  try {
                    await ref
                        .read(activeTransitControllerProvider.notifier)
                        .startCommute(item.schedule.id);
                    if (context.mounted) context.go('/active');
                  } catch (error) {
                    if (context.mounted) _showMessage(context, '$error');
                  }
                },
                onActionSelected: (action) =>
                    _handleAction(context, ref, item, action),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New schedule'),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    ScheduleWithSegments item,
    ScheduleCardAction action,
  ) async {
    switch (action) {
      case ScheduleCardAction.edit:
        await _openEditor(context, ref, initial: item);
        return;
      case ScheduleCardAction.activate:
      case ScheduleCardAction.deactivate:
        try {
          await ref
              .read(scheduleControllerProvider.notifier)
              .setActive(
                item.schedule.id,
                action == ScheduleCardAction.activate,
              );
        } catch (error) {
          if (context.mounted) _showMessage(context, '$error');
        }
        return;
      case ScheduleCardAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete schedule?'),
            content: Text(
              'Delete "${item.schedule.name}"? Past commute logs are kept, but the schedule link will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep schedule'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        try {
          await ref
              .read(scheduleControllerProvider.notifier)
              .deleteSchedule(item.schedule.id);
        } catch (error) {
          if (context.mounted) _showMessage(context, '$error');
        }
        return;
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    ScheduleWithSegments? initial,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ScheduleEditorSheet(initial: initial),
    );
    if (saved == true) {
      ref.invalidate(scheduleVarianceProvider);
      ref.invalidate(segmentAveragesProvider);
      ref.invalidate(schedulesProvider);
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ScheduleManagementCard extends ConsumerWidget {
  const _ScheduleManagementCard({
    required this.schedule,
    required this.isCurrentCommute,
    required this.onCommutePressed,
    required this.onActionSelected,
  });

  final ScheduleWithSegments schedule;
  final bool isCurrentCommute;
  final VoidCallback onCommutePressed;
  final ValueChanged<ScheduleCardAction> onActionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variance = ref.watch(scheduleVarianceProvider(schedule.schedule.id));
    return variance.when(
      loading: () => const Card(
        child: SizedBox(
          height: 190,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Could not load commute averages: $error'),
        ),
      ),
      data: (value) => ScheduleCard(
        schedule: schedule,
        variance: value,
        isCurrentCommute: isCurrentCommute,
        onCommutePressed: (_) => onCommutePressed(),
        onActionSelected: onActionSelected,
      ),
    );
  }
}

class _ScheduleEditorSheet extends ConsumerStatefulWidget {
  const _ScheduleEditorSheet({this.initial});

  final ScheduleWithSegments? initial;

  @override
  ConsumerState<_ScheduleEditorSheet> createState() =>
      _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends ConsumerState<_ScheduleEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _startController;
  late final TextEditingController _arrivalController;
  late final Set<int> _selectedDays;
  late final List<_SegmentDraft> _segments;
  bool _saving = false;

  static const _modes = [
    'walk',
    'bus',
    'train',
    'minibus',
    'car',
    'motorcycle',
    'bike',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    final schedule = widget.initial;
    _nameController = TextEditingController(
      text: schedule?.schedule.name ?? '',
    );
    _startController = TextEditingController(
      text: schedule?.schedule.targetStartTime ?? '08:00',
    );
    _arrivalController = TextEditingController(
      text: schedule?.schedule.targetArrivalTime ?? '09:00',
    );
    _selectedDays = {...?schedule?.schedule.daysOfWeek};
    _segments = schedule == null || schedule.segments.isEmpty
        ? [_SegmentDraft()]
        : [
            for (final segment in schedule.segments)
              _SegmentDraft(
                name: segment.name,
                mode: _modes.contains(segment.transportMode)
                    ? segment.transportMode
                    : 'other',
                duration: segment.estimatedDurationMinutes,
              ),
          ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _arrivalController.dispose();
    for (final segment in _segments) {
      segment.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.55,
        builder: (context, scrollController) => Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.initial == null ? 'New schedule' : 'Edit schedule',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    maxLength: 100,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Schedule name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a schedule name'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: 'Start time',
                          controller: _startController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeField(
                          label: 'Arrival time',
                          controller: _arrivalController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Days of week',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (var day = 1; day <= 7; day++)
                        _DayChoice(
                          day: day,
                          selected: _selectedDays.contains(day),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day);
                              } else {
                                _selectedDays.remove(day);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Route segments',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addSegment,
                        icon: const Icon(Icons.add),
                        label: const Text('Add segment'),
                      ),
                    ],
                  ),
                  for (var index = 0; index < _segments.length; index++)
                    _SegmentEditor(
                      key: ObjectKey(_segments[index]),
                      index: index,
                      draft: _segments[index],
                      modes: _modes,
                      canRemove: _segments.length > 1,
                      onRemove: () => _removeSegment(index),
                      onModeChanged: (mode) {
                        setState(() => _segments[index].mode = mode);
                      },
                    ),
                  if (_segments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Add at least one route segment.'),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving…' : 'Save schedule'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addSegment() {
    setState(() => _segments.add(_SegmentDraft()));
  }

  void _removeSegment(int index) {
    final segment = _segments.removeAt(index);
    segment.dispose();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      _showError('Select at least one day of the week.');
      return;
    }
    if (_segments.isEmpty) {
      _showError('Add at least one route segment.');
      return;
    }

    final segmentCompanions = <ScheduleSegmentsCompanion>[];
    for (var index = 0; index < _segments.length; index++) {
      final draft = _segments[index];
      final duration = int.tryParse(draft.durationController.text.trim());
      if (draft.nameController.text.trim().isEmpty ||
          duration == null ||
          duration < 1) {
        _showError(
          'Each segment needs a name and a duration of at least one minute.',
        );
        return;
      }
      segmentCompanions.add(
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: draft.nameController.text.trim(),
          transportMode: draft.mode,
          orderIndex: index,
          estimatedDurationMinutes: duration,
        ),
      );
    }

    final scheduleValues = SchedulesCompanion(
      name: Value(_nameController.text.trim()),
      targetStartTime: Value(_startController.text),
      targetArrivalTime: Value(_arrivalController.text),
      daysOfWeek: Value(_selectedDays.toList()..sort()),
      isActive: widget.initial == null
          ? const Value.absent()
          : Value(widget.initial!.schedule.isActive),
    );
    setState(() => _saving = true);
    try {
      final controller = ref.read(scheduleControllerProvider.notifier);
      if (widget.initial == null) {
        await controller.createSchedule(
          schedule: scheduleValues,
          segments: segmentCompanions,
        );
      } else {
        await controller.updateSchedule(
          scheduleId: widget.initial!.schedule.id,
          schedule: scheduleValues,
          segments: segmentCompanions,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      _showError('$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final current =
            _parseTime(controller.text) ?? const TimeOfDay(hour: 8, minute: 0);
        final selected = await showTimePicker(
          context: context,
          initialTime: current,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (selected != null) {
          controller.text =
              '${selected.hour.toString().padLeft(2, '0')}:'
              '${selected.minute.toString().padLeft(2, '0')}';
        }
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      validator: (value) {
        try {
          CommonUtilities.parseHHmmToMinutes(value ?? '');
          return null;
        } on FormatException {
          return 'Select a valid time';
        }
      },
    );
  }

  static TimeOfDay? _parseTime(String value) {
    try {
      final minutes = CommonUtilities.parseHHmmToMinutes(value);
      return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    } on FormatException {
      return null;
    }
  }
}

class _DayChoice extends StatelessWidget {
  const _DayChoice({
    required this.day,
    required this.selected,
    required this.onSelected,
  });

  final int day;
  final bool selected;
  final ValueChanged<bool> onSelected;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(_labels[day - 1]),
      selected: selected,
      onSelected: onSelected,
      tooltip: const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][day - 1],
    );
  }
}

class _SegmentDraft {
  _SegmentDraft({String name = '', this.mode = 'walk', int duration = 10})
    : nameController = TextEditingController(text: name),
      durationController = TextEditingController(text: '$duration');

  final TextEditingController nameController;
  final TextEditingController durationController;
  String mode;

  void dispose() {
    nameController.dispose();
    durationController.dispose();
  }
}

class _SegmentEditor extends StatelessWidget {
  const _SegmentEditor({
    required this.index,
    required this.draft,
    required this.modes,
    required this.canRemove,
    required this.onRemove,
    required this.onModeChanged,
    super.key,
  });

  final int index;
  final _SegmentDraft draft;
  final List<String> modes;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<String> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Segment ${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove segment',
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFormField(
              controller: draft.nameController,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Segment name',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a segment name'
                  : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: draft.mode,
                    decoration: const InputDecoration(
                      labelText: 'Transport',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final mode in modes)
                        DropdownMenuItem(
                          value: mode,
                          child: Text(
                            '${mode[0].toUpperCase()}${mode.substring(1)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) onModeChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 105,
                  child: TextFormField(
                    controller: draft.durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final minutes = int.tryParse(value ?? '');
                      return minutes == null || minutes < 1 ? '1+' : null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleEmptyState extends StatelessWidget {
  const _ScheduleEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              'No schedules yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Add your route and transport segments to get started.'),
          ],
        ),
      ),
    );
  }
}

class _ScheduleError extends StatelessWidget {
  const _ScheduleError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
