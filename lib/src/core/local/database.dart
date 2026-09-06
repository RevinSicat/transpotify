import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/schedules.dart';
import 'tables/schedule_segments.dart';
import 'tables/transit_logs.dart';
import 'tables/transit_segment_logs.dart';

part 'database.g.dart';

@DriftDatabase(
	tables: [Schedules, ScheduleSegments, TransitLogs, TransitSegmentLogs],
)
class AppDatabase extends _$AppDatabase {
	AppDatabase() : super(_openConnection());

	@override
	int get schemaVersion => 2;

	@override
	MigrationStrategy get migration => MigrationStrategy(
		onCreate: (Migrator m) async {
			await m.createAll();
			await _createIndices(m);
		},
		onUpgrade: (Migrator m, int from, int to) async {
			if (from < 2) {
				await m.addColumn(scheduleSegments, scheduleSegments.name);
			}
		},
		beforeOpen: (details) async {
			await customStatement('PRAGMA foreign_keys = ON');
		},
	);

	Future<void> _createIndices(Migrator m) async {
		await customStatement(
			'CREATE INDEX idx_schedule_segments_schedule_id ON schedule_segments(schedule_id);',
		);
		await customStatement(
			'CREATE INDEX idx_transit_logs_schedule_id ON transit_logs(schedule_id);',
		);
		await customStatement(
			'CREATE INDEX idx_transit_logs_date ON transit_logs(date);',
		);
		await customStatement(
			'CREATE INDEX idx_transit_seg_logs_transit_log_id ON transit_segment_logs(transit_log_id);',
		);
	}
}

LazyDatabase _openConnection() {
	return LazyDatabase(() async {
		final dbFolder = await getApplicationDocumentsDirectory();
		final file = File(p.join(dbFolder.path, 'transpotify.sqlite'));
		return NativeDatabase.createInBackground(file);
	});
}
