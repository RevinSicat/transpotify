import 'package:drift/drift.dart';

import 'package:transpotify/src/core/local/database.dart';
import 'package:transpotify/src/core/local/base_repository.dart';
import 'package:transpotify/src/core/local/tables/transit_logs.dart';

import 'transit_log_dao.dart';

class TransitLogRepository extends BaseRepository<TransitLogs, TransitLog> {
    TransitLogRepository(TransitLogDao dao) : super(dao);

    Future<int> addTransitLog(Insertable<TransitLog> log) {
        return dao.insertItem(log);
    }

    Future<bool> updateTransitLog(Insertable<TransitLog> log) {
        return dao.updateItem(log);
    }

    Future<int> deleteTransitLogById(int id) {
        return dao.deleteWhere((tbl) => tbl.id.equals(id));
    }
}