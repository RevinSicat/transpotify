import 'package:drift/drift.dart';
import 'base_dao.dart';

abstract class BaseRepository<T extends Table, D> {
    final BaseDao<T, D> dao;

    const BaseRepository(this.dao);

    Stream<List<D>> watchAll() => dao.watchAll();

    Future<List<D>> getAll() => dao.getAll();
}
