import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/local/database.dart';
import '../../../../core/local/providers.dart';
import 'package:transpotify/src/common/utils/common_utilities.dart';

import '../components/segment_draft.dart';
import '../components/schedule_editor_top_bar.dart';
import '../components/schedule_editor_stepper.dart';
import '../components/schedule_time_card.dart';
import '../components/schedule_days_selector.dart';
import '../components/schedule_transit_mode_picker.dart';
import '../components/schedule_editor_action_buttons.dart';
import '../components/schedule_segment_editor_tile.dart';

class ScheduleEditorPage extends ConsumerStatefulWidget {
    final int? scheduleId;

    const ScheduleEditorPage({
        super.key,
        this.scheduleId,
    });

    @override
    ConsumerState<ScheduleEditorPage> createState() => _ScheduleEditorPageState();
}

class _ScheduleEditorPageState extends ConsumerState<ScheduleEditorPage> {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: 'New Commute Schedule');
    final selectedDays = <String>{};
    final segments = <SegmentDraft>[];

    TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
    TimeOfDay arrivalTime = const TimeOfDay(hour: 0, minute: 0);
    bool isActive = true;
    bool isSaving = false;
    bool isLoading = false;
    int currentStep = 0;

    @override
    void initState() {
        super.initState();
        if (widget.scheduleId != null) {
            loadExistingSchedule();
        }
    }

    Future<void> loadExistingSchedule() async {
        setState(() => isLoading = true);
        try {
            final repository = ref.read(scheduleRepositoryProvider);
            final schedule = await repository.getScheduleById(widget.scheduleId!);
            if (schedule != null) {
                final loadedSegments =
                    await repository.getSegmentsForSchedule(widget.scheduleId!);
                if (mounted) {
                    setState(() {
                        nameController.text = schedule.name;
                        startTime = CommonUtilities.minutesToTime(schedule.targetStartTime);
                        arrivalTime = CommonUtilities.minutesToTime(schedule.targetArrivalTime);
                        selectedDays.clear();
                        selectedDays.addAll(
                            schedule.daysOfWeek.split(',').where((d) => d.isNotEmpty),
                        );
                        isActive = schedule.isActive;
                        segments.clear();
                        for (final seg in loadedSegments) {
                            final draft = SegmentDraft(seg.transportMode);
                            draft.nameController.text = seg.name;
                            if (seg.estimatedDurationMinutes != null) {
                                draft.durationController.text =
                                    seg.estimatedDurationMinutes.toString();
                            }
                            segments.add(draft);
                        }
                    });
                }
            }
        } catch (error) {
            if (mounted) {
                CommonUtilities.showMessage(
                    context,
                    'Could not load schedule: $error',
                );
            }
        } finally {
            if (mounted) setState(() => isLoading = false);
        }
    }

    @override
    void dispose() {
        nameController.dispose();
        for (final segment in segments) {
            segment.dispose();
        }
        super.dispose();
    }

    int get durationMinutes =>
        CommonUtilities.durationMinutes(startTime, arrivalTime);

    String get durationSummary =>
        CommonUtilities.formatDurationSummary(durationMinutes);

    int get totalSegmentMinutes {
        var total = 0;
        for (final segment in segments) {
            total += int.tryParse(segment.durationController.text.trim()) ?? 0;
        }
        return total;
    }

    Future<void> pickTime({required bool isStart}) async {
        final selected = await showTimePicker(
            context: context,
            initialTime: isStart ? startTime : arrivalTime,
            builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFF0051D5),
                        ),
                    ),
                    child: child!,
                );
            },
        );
        if (selected == null) return;

        setState(() {
            if (isStart) {
                startTime = selected;
            } else {
                arrivalTime = selected;
            }
        });
    }

    void addSegment(String mode) {
        setState(() {
            segments.add(SegmentDraft(mode));
        });
    }

    void removeSegment(int index) {
        setState(() {
            final removed = segments.removeAt(index);
            removed.dispose();
        });
    }

    void reorderSegments(int oldIndex, int newIndex) {
        setState(() {
            final item = segments.removeAt(oldIndex);
            segments.insert(newIndex, item);
        });
    }

    void toggleDay(String day) {
        setState(() {
            if (selectedDays.contains(day)) {
                selectedDays.remove(day);
            } else {
                selectedDays.add(day);
            }
        });
    }

    Future<void> saveSchedule() async {
        if (!formKey.currentState!.validate()) return;
        if (durationMinutes < 0) {
            CommonUtilities.showMessage(
                context,
                'Arrival time cannot be before start time.',
            );
            return;
        }
        if (selectedDays.isEmpty) {
            CommonUtilities.showMessage(
                context,
                'Select at least one active day.',
            );
            return;
        }

        setState(() => isSaving = true);
        try {
            final repository = ref.read(scheduleRepositoryProvider);
            final scheduleCompanion = SchedulesCompanion(
                name: Value(nameController.text.trim()),
                targetStartTime: Value(CommonUtilities.timeToMinutes(startTime)),
                targetArrivalTime: Value(CommonUtilities.timeToMinutes(arrivalTime)),
                daysOfWeek: Value(
                    ScheduleDaysSelector.days
                        .where(selectedDays.contains)
                        .join(','),
                ),
                isActive: Value(isActive),
            );

            if (widget.scheduleId != null) {
                final segmentCompanions = <ScheduleSegmentsCompanion>[];
                for (var index = 0; index < segments.length; index++) {
                    final segment = segments[index];
                    segmentCompanions.add(
                        ScheduleSegmentsCompanion.insert(
                            scheduleId: widget.scheduleId!,
                            transportMode: segment.mode,
                            name: Value(
                                segment.nameController.text.trim().isEmpty
                                    ? segment.mode
                                    : segment.nameController.text.trim(),
                            ),
                            orderIndex: index,
                            estimatedDurationMinutes: Value(
                                int.tryParse(segment.durationController.text.trim()),
                            ),
                        ),
                    );
                }
                await repository.updateScheduleWithSegments(
                    scheduleId: widget.scheduleId!,
                    scheduleCompanion: scheduleCompanion,
                    segmentCompanions: segmentCompanions,
                );
            } else {
                final database = ref.read(appDatabaseProvider);
                await database.transaction(() async {
                    final scheduleId = await database.into(database.schedules).insert(
                        SchedulesCompanion.insert(
                            name: nameController.text.trim(),
                            targetStartTime: CommonUtilities.timeToMinutes(startTime),
                            targetArrivalTime: CommonUtilities.timeToMinutes(arrivalTime),
                            daysOfWeek: ScheduleDaysSelector.days
                                .where(selectedDays.contains)
                                .join(','),
                            isActive: Value(isActive),
                        ),
                    );

                    for (var index = 0; index < segments.length; index++) {
                        final segment = segments[index];
                        await database.into(database.scheduleSegments).insert(
                            ScheduleSegmentsCompanion.insert(
                                scheduleId: scheduleId,
                                transportMode: segment.mode,
                                name: Value(
                                    segment.nameController.text.trim().isEmpty
                                        ? segment.mode
                                        : segment.nameController.text.trim(),
                                ),
                                orderIndex: index,
                                estimatedDurationMinutes: Value(
                                    int.tryParse(segment.durationController.text.trim()),
                                ),
                            ),
                        );
                    }
                });
            }
            if (mounted) context.pop();
        } catch (error) {
            if (mounted) {
                CommonUtilities.showMessage(
                    context,
                    'Could not save schedule: $error',
                );
            }
        } finally {
            if (mounted) setState(() => isSaving = false);
        }
    }

    @override
    Widget build(BuildContext context) {
        if (isLoading) {
            return const Scaffold(
                backgroundColor: Color(0xFFF6F8FC),
                body: Center(child: CircularProgressIndicator()),
            );
        }

        return Scaffold(
            backgroundColor: const Color(0xFFF6F8FC),
            body: SafeArea(
                child: Form(
                    key: formKey,
                    child: Column(
                        children: [
                            ScheduleEditorTopBar(
                                title: widget.scheduleId != null
                                    ? 'Edit Commute Schedule'
                                    : 'New Commute Schedule',
                                onClose: () => context.pop(),
                            ),
                            ScheduleEditorStepper(
                                currentStep: currentStep,
                                onStepTapped: (step) => setState(() => currentStep = step),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                                child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Column(
                                        children: [
                                            if (currentStep == 0)
                                                buildScheduleDetailsCard()
                                            else
                                                buildTransitLegsCard(),
                                            const SizedBox(height: 16),
                                            ScheduleEditorActionButtons(
                                                currentStep: currentStep,
                                                isSaving: isSaving,
                                                onSave: saveSchedule,
                                                onNext: () => setState(() => currentStep = 1),
                                                onBack: () => setState(() => currentStep = 0),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget buildScheduleDetailsCard() {
        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.edit_note_rounded,
                                    size: 20,
                                    color: Color(0xFF0051D5),
                                ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: TextFormField(
                                    controller: nameController,
                                    textCapitalization: TextCapitalization.words,
                                    maxLength: 50,
                                    inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                    ],
                                    buildCounter: (
                                        context, {
                                        required currentLength,
                                        required isFocused,
                                        maxLength,
                                    }) =>
                                        null,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                    ),
                                    decoration: const InputDecoration(
                                        hintText: 'Schedule Name',
                                        hintStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF94A3B8),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                    ),
                                    validator: (value) => value == null || value.trim().isEmpty
                                        ? 'Enter a schedule name'
                                        : null,
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                        children: [
                            Expanded(
                                child: ScheduleTimeCard(
                                    isStart: true,
                                    time: startTime,
                                    onTap: () => pickTime(isStart: true),
                                ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: ScheduleTimeCard(
                                    isStart: false,
                                    time: arrivalTime,
                                    onTap: () => pickTime(isStart: false),
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                        ),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FE),
                            borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                            children: [
                                const Icon(
                                    Icons.timelapse_rounded,
                                    size: 20,
                                    color: Color(0xFF0051D5),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                    'Target Window Duration',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                    ),
                                ),
                                const Spacer(),
                                Text(
                                    durationSummary,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: durationMinutes < 0
                                            ? Colors.red
                                            : const Color(0xFF0051D5),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 18),
                    ScheduleDaysSelector(
                        selectedDays: selectedDays,
                        onDayToggled: toggleDay,
                    ),
                    const SizedBox(height: 20),
                    Row(
                        children: [
                            const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        'Is Active Schedule',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                        ),
                                    ),
                                ],
                            ),
                            const Spacer(),
                            Switch.adaptive(
                                value: isActive,
                                activeTrackColor: const Color(0xFF0051D5),
                                activeThumbColor: Colors.white,
                                onChanged: (value) => setState(() => isActive = value),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    Widget buildTransitLegsCard() {
        return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FE),
                            borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                            children: [
                                const Icon(
                                    Icons.route_outlined,
                                    size: 18,
                                    color: Color(0xFF0051D5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    '${segments.length} ${segments.length == 1 ? 'leg' : 'legs'} defined',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                    ),
                                ),
                                const Spacer(),
                                Text(
                                    'Total ~$totalSegmentMinutes mins',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0051D5),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 16),
                    if (segments.isNotEmpty)
                        ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: segments.length,
                            onReorderItem: reorderSegments,
                            itemBuilder: (context, index) {
                                final segment = segments[index];
                                return ScheduleSegmentEditorTile(
                                    key: ValueKey(segment),
                                    itemKey: ValueKey(segment),
                                    index: index,
                                    mode: segment.mode,
                                    nameController: segment.nameController,
                                    durationController: segment.durationController,
                                    onRemove: () => removeSegment(index),
                                );
                            },
                        )
                    else
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFD),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    style: BorderStyle.solid,
                                ),
                            ),
                            child: const Column(
                                children: [
                                    Icon(
                                        Icons.add_road_rounded,
                                        size: 32,
                                        color: Color(0xFF94A3B8),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        'No transit legs added yet',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF475569),
                                        ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                        'Tap a transit mode below to add your commute steps',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    const SizedBox(height: 18),
                    ScheduleTransitModePicker(
                        onModeSelected: addSegment,
                    ),
                ],
            ),
        );
    }
}
