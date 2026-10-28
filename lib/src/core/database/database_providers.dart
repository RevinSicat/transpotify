import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'schedule/dao/schedule_dao.dart';
import 'transit/dao/transit_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final scheduleDaoProvider = Provider<ScheduleDao>(
  (ref) => ref.watch(appDatabaseProvider).scheduleDao,
);

final transitDaoProvider = Provider<TransitDao>(
  (ref) => ref.watch(appDatabaseProvider).transitDao,
);
