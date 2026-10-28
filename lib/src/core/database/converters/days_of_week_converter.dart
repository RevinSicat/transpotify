import 'dart:convert';
import 'package:drift/drift.dart';

/// Converts a list of day numbers (e.g., [1, 2, 3, 4, 5] for Mon-Fri) into a JSON string for SQLite storage.
class DaysOfWeekConverter extends TypeConverter<List<int>, String> {
    const DaysOfWeekConverter();

    @override
    List<int> fromSql(String fromDb) {
        if (fromDb.isEmpty) return [];
        return (jsonDecode(fromDb) as List<dynamic>).cast<int>();
    }

    @override
    String toSql(List<int> value) {
        return jsonEncode(value);
    }
}