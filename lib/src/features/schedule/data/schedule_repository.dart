import 'package:drift/drift.dart';

import 'package:transpotify/src/core/local/database.dart';
import 'package:transpotify/src/core/local/base_repository.dart';

import 'schedule_dao.dart';

import 'package:transpotify/src/core/local/tables/schedules.dart';

class ScheduleRepository extends BaseRepository<Schedules, Schedule> {
    ScheduleRepository(super.dao);

    Future<int> addSchedule(Insertable<Schedule> schedule) {
        return dao.insertItem(schedule);
    }

    Future<bool> updateSchedule(Insertable<Schedule> schedule) {
        return dao.updateItem(schedule);
    }

    Future<int> deleteScheduleById(int id) {
        return dao.deleteWhere((tbl) => tbl.id.equals(id));
    }

    Future<Schedule?> getScheduleById(int id) {
        return dao.getSingleWhere((tbl) => tbl.id.equals(id));
    }

    Future<List<ScheduleSegment>> getSegmentsForSchedule(int scheduleId) {
        return (dao.db.select(dao.db.scheduleSegments)
            ..where((tbl) => tbl.scheduleId.equals(scheduleId))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
            .get();
    }

    Future<void> deleteScheduleWithSegments(int scheduleId) async {
        await dao.db.transaction(() async {
            await (dao.db.delete(dao.db.scheduleSegments)
                ..where((tbl) => tbl.scheduleId.equals(scheduleId)))
                .go();
            await (dao.db.delete(dao.db.schedules)
                ..where((tbl) => tbl.id.equals(scheduleId)))
                .go();
        });
    }

    Future<void> updateScheduleWithSegments({
        required int scheduleId,
        required SchedulesCompanion scheduleCompanion,
        required List<ScheduleSegmentsCompanion> segmentCompanions,
    }) async {
        await dao.db.transaction(() async {
            await (dao.db.update(dao.db.schedules)
                ..where((tbl) => tbl.id.equals(scheduleId)))
                .write(scheduleCompanion);
            await (dao.db.delete(dao.db.scheduleSegments)
                ..where((tbl) => tbl.scheduleId.equals(scheduleId)))
                .go();
            for (final segment in segmentCompanions) {
                await dao.db.into(dao.db.scheduleSegments).insert(segment);
            }
        });
    }
}

