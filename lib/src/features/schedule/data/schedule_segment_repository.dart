import 'package:drift/drift.dart';

import 'package:transpotify/src/core/local/database.dart';
import 'package:transpotify/src/core/local/base_repository.dart';
import 'package:transpotify/src/core/local/tables/schedule_segments.dart';

import 'schedule_segment_dao.dart';

class ScheduleSegmentRepository extends BaseRepository<ScheduleSegments, ScheduleSegment> {
    ScheduleSegmentRepository(ScheduleSegmentDao dao) : super(dao);

    Future<int> addScheduleSegment(Insertable<ScheduleSegment> segment) {
        return dao.insertItem(segment);
    }

    Future<bool> updateScheduleSegment(Insertable<ScheduleSegment> segment) {
        return dao.updateItem(segment);
    }

    Future<int> deleteScheduleSegmentById(int id) {
        return dao.deleteWhere((tbl) => tbl.id.equals(id));
    }
}