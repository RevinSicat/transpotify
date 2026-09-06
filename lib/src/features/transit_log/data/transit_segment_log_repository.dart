import 'package:drift/drift.dart';

import 'package:transpotify/src/core/local/database.dart';
import 'package:transpotify/src/core/local/base_repository.dart';
import 'package:transpotify/src/core/local/tables/transit_segment_logs.dart';

import 'transit_segment_log_dao.dart';

class TransitSegmentLogRepository extends BaseRepository<TransitSegmentLogs, TransitSegmentLog> {
    TransitSegmentLogRepository(TransitSegmentLogDao dao) : super(dao);

    Future<int> addSegmentLog(Insertable<TransitSegmentLog> segmentLog) {
        return dao.insertItem(segmentLog);
    }

    Future<bool> updateSegmentLog(Insertable<TransitSegmentLog> segmentLog) {
        return dao.updateItem(segmentLog);
    }

    Future<int> deleteSegmentLogById(int id) {
        return dao.deleteWhere((tbl) => tbl.id.equals(id));
    }
}