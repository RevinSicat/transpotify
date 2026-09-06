import 'package:drift/drift.dart';
import 'database.dart';

abstract class BaseDao<T extends Table, D> extends DatabaseAccessor<AppDatabase> {
    BaseDao(super.db);

    TableInfo<T, D> get table;

    Future<int> insertItem(Insertable<D> entry) => into(table).insert(entry);

    Future<int> insertOrReplaceItem(Insertable<D> entry) => into(table).insertOnConflictUpdate(entry);

    Future<bool> updateItem(Insertable<D> entry) => update(table).replace(entry);

    Future<int> deleteWhere(Expression<bool> Function(T) filter) => (delete(table)..where(filter)).go();

    Future<List<D>> getAll() => select(table).get();

    Stream<List<D>> watchAll() => select(table).watch();

    Future<D?> getSingleWhere(Expression<bool> Function(T) filter) => (select(table)..where(filter)).getSingleOrNull();

    Stream<List<D>> watchWhere(Expression<bool> Function(T) filter) => (select(table)..where(filter)).watch();
}
