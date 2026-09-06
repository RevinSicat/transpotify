// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetStartTimeMeta = const VerificationMeta(
    'targetStartTime',
  );
  @override
  late final GeneratedColumn<int> targetStartTime = GeneratedColumn<int>(
    'target_start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetArrivalTimeMeta = const VerificationMeta(
    'targetArrivalTime',
  );
  @override
  late final GeneratedColumn<int> targetArrivalTime = GeneratedColumn<int>(
    'target_arrival_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetStartTime,
    targetArrivalTime,
    daysOfWeek,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Schedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_start_time')) {
      context.handle(
        _targetStartTimeMeta,
        targetStartTime.isAcceptableOrUnknown(
          data['target_start_time']!,
          _targetStartTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetStartTimeMeta);
    }
    if (data.containsKey('target_arrival_time')) {
      context.handle(
        _targetArrivalTimeMeta,
        targetArrivalTime.isAcceptableOrUnknown(
          data['target_arrival_time']!,
          _targetArrivalTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetArrivalTimeMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysOfWeekMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetStartTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_start_time'],
      )!,
      targetArrivalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_arrival_time'],
      )!,
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final int id;
  final String name;
  final int targetStartTime;
  final int targetArrivalTime;
  final String daysOfWeek;
  final bool isActive;
  const Schedule({
    required this.id,
    required this.name,
    required this.targetStartTime,
    required this.targetArrivalTime,
    required this.daysOfWeek,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_start_time'] = Variable<int>(targetStartTime);
    map['target_arrival_time'] = Variable<int>(targetArrivalTime);
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      name: Value(name),
      targetStartTime: Value(targetStartTime),
      targetArrivalTime: Value(targetArrivalTime),
      daysOfWeek: Value(daysOfWeek),
      isActive: Value(isActive),
    );
  }

  factory Schedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetStartTime: serializer.fromJson<int>(json['targetStartTime']),
      targetArrivalTime: serializer.fromJson<int>(json['targetArrivalTime']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetStartTime': serializer.toJson<int>(targetStartTime),
      'targetArrivalTime': serializer.toJson<int>(targetArrivalTime),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Schedule copyWith({
    int? id,
    String? name,
    int? targetStartTime,
    int? targetArrivalTime,
    String? daysOfWeek,
    bool? isActive,
  }) => Schedule(
    id: id ?? this.id,
    name: name ?? this.name,
    targetStartTime: targetStartTime ?? this.targetStartTime,
    targetArrivalTime: targetArrivalTime ?? this.targetArrivalTime,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    isActive: isActive ?? this.isActive,
  );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetStartTime: data.targetStartTime.present
          ? data.targetStartTime.value
          : this.targetStartTime,
      targetArrivalTime: data.targetArrivalTime.present
          ? data.targetArrivalTime.value
          : this.targetArrivalTime,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetStartTime: $targetStartTime, ')
          ..write('targetArrivalTime: $targetArrivalTime, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetStartTime,
    targetArrivalTime,
    daysOfWeek,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetStartTime == this.targetStartTime &&
          other.targetArrivalTime == this.targetArrivalTime &&
          other.daysOfWeek == this.daysOfWeek &&
          other.isActive == this.isActive);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> targetStartTime;
  final Value<int> targetArrivalTime;
  final Value<String> daysOfWeek;
  final Value<bool> isActive;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetStartTime = const Value.absent(),
    this.targetArrivalTime = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int targetStartTime,
    required int targetArrivalTime,
    required String daysOfWeek,
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       targetStartTime = Value(targetStartTime),
       targetArrivalTime = Value(targetArrivalTime),
       daysOfWeek = Value(daysOfWeek);
  static Insertable<Schedule> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? targetStartTime,
    Expression<int>? targetArrivalTime,
    Expression<String>? daysOfWeek,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetStartTime != null) 'target_start_time': targetStartTime,
      if (targetArrivalTime != null) 'target_arrival_time': targetArrivalTime,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (isActive != null) 'is_active': isActive,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? targetStartTime,
    Value<int>? targetArrivalTime,
    Value<String>? daysOfWeek,
    Value<bool>? isActive,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetStartTime: targetStartTime ?? this.targetStartTime,
      targetArrivalTime: targetArrivalTime ?? this.targetArrivalTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetStartTime.present) {
      map['target_start_time'] = Variable<int>(targetStartTime.value);
    }
    if (targetArrivalTime.present) {
      map['target_arrival_time'] = Variable<int>(targetArrivalTime.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetStartTime: $targetStartTime, ')
          ..write('targetArrivalTime: $targetArrivalTime, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $ScheduleSegmentsTable extends ScheduleSegments
    with TableInfo<$ScheduleSegmentsTable, ScheduleSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedules (id)',
    ),
  );
  static const VerificationMeta _transportModeMeta = const VerificationMeta(
    'transportMode',
  );
  @override
  late final GeneratedColumn<String> transportMode = GeneratedColumn<String>(
    'transport_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>(
        'estimated_duration_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduleId,
    transportMode,
    name,
    orderIndex,
    estimatedDurationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('transport_mode')) {
      context.handle(
        _transportModeMeta,
        transportMode.isAcceptableOrUnknown(
          data['transport_mode']!,
          _transportModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transportModeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
        _estimatedDurationMinutesMeta,
        estimatedDurationMinutes.isAcceptableOrUnknown(
          data['estimated_duration_minutes']!,
          _estimatedDurationMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      )!,
      transportMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transport_mode'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_minutes'],
      ),
    );
  }

  @override
  $ScheduleSegmentsTable createAlias(String alias) {
    return $ScheduleSegmentsTable(attachedDatabase, alias);
  }
}

class ScheduleSegment extends DataClass implements Insertable<ScheduleSegment> {
  final int id;
  final int scheduleId;
  final String transportMode;
  final String name;
  final int orderIndex;
  final int? estimatedDurationMinutes;
  const ScheduleSegment({
    required this.id,
    required this.scheduleId,
    required this.transportMode,
    required this.name,
    required this.orderIndex,
    this.estimatedDurationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schedule_id'] = Variable<int>(scheduleId);
    map['transport_mode'] = Variable<String>(transportMode);
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || estimatedDurationMinutes != null) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes,
      );
    }
    return map;
  }

  ScheduleSegmentsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleSegmentsCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      transportMode: Value(transportMode),
      name: Value(name),
      orderIndex: Value(orderIndex),
      estimatedDurationMinutes: estimatedDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDurationMinutes),
    );
  }

  factory ScheduleSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleSegment(
      id: serializer.fromJson<int>(json['id']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      transportMode: serializer.fromJson<String>(json['transportMode']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      estimatedDurationMinutes: serializer.fromJson<int?>(
        json['estimatedDurationMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'transportMode': serializer.toJson<String>(transportMode),
      'name': serializer.toJson<String>(name),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'estimatedDurationMinutes': serializer.toJson<int?>(
        estimatedDurationMinutes,
      ),
    };
  }

  ScheduleSegment copyWith({
    int? id,
    int? scheduleId,
    String? transportMode,
    String? name,
    int? orderIndex,
    Value<int?> estimatedDurationMinutes = const Value.absent(),
  }) => ScheduleSegment(
    id: id ?? this.id,
    scheduleId: scheduleId ?? this.scheduleId,
    transportMode: transportMode ?? this.transportMode,
    name: name ?? this.name,
    orderIndex: orderIndex ?? this.orderIndex,
    estimatedDurationMinutes: estimatedDurationMinutes.present
        ? estimatedDurationMinutes.value
        : this.estimatedDurationMinutes,
  );
  ScheduleSegment copyWithCompanion(ScheduleSegmentsCompanion data) {
    return ScheduleSegment(
      id: data.id.present ? data.id.value : this.id,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      transportMode: data.transportMode.present
          ? data.transportMode.value
          : this.transportMode,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSegment(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('transportMode: $transportMode, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduleId,
    transportMode,
    name,
    orderIndex,
    estimatedDurationMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleSegment &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.transportMode == this.transportMode &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes);
}

class ScheduleSegmentsCompanion extends UpdateCompanion<ScheduleSegment> {
  final Value<int> id;
  final Value<int> scheduleId;
  final Value<String> transportMode;
  final Value<String> name;
  final Value<int> orderIndex;
  final Value<int?> estimatedDurationMinutes;
  const ScheduleSegmentsCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.transportMode = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
  });
  ScheduleSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required int scheduleId,
    required String transportMode,
    this.name = const Value.absent(),
    required int orderIndex,
    this.estimatedDurationMinutes = const Value.absent(),
  }) : scheduleId = Value(scheduleId),
       transportMode = Value(transportMode),
       orderIndex = Value(orderIndex);
  static Insertable<ScheduleSegment> custom({
    Expression<int>? id,
    Expression<int>? scheduleId,
    Expression<String>? transportMode,
    Expression<String>? name,
    Expression<int>? orderIndex,
    Expression<int>? estimatedDurationMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (transportMode != null) 'transport_mode': transportMode,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
    });
  }

  ScheduleSegmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? scheduleId,
    Value<String>? transportMode,
    Value<String>? name,
    Value<int>? orderIndex,
    Value<int?>? estimatedDurationMinutes,
  }) {
    return ScheduleSegmentsCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      transportMode: transportMode ?? this.transportMode,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (transportMode.present) {
      map['transport_mode'] = Variable<String>(transportMode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('transportMode: $transportMode, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes')
          ..write(')'))
        .toString();
  }
}

class $TransitLogsTable extends TransitLogs
    with TableInfo<$TransitLogsTable, TransitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedules (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, scheduleId, date, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransitLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $TransitLogsTable createAlias(String alias) {
    return $TransitLogsTable(attachedDatabase, alias);
  }
}

class TransitLog extends DataClass implements Insertable<TransitLog> {
  final int id;
  final int scheduleId;
  final DateTime date;
  final String status;
  const TransitLog({
    required this.id,
    required this.scheduleId,
    required this.date,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schedule_id'] = Variable<int>(scheduleId);
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    return map;
  }

  TransitLogsCompanion toCompanion(bool nullToAbsent) {
    return TransitLogsCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      date: Value(date),
      status: Value(status),
    );
  }

  factory TransitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransitLog(
      id: serializer.fromJson<int>(json['id']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
    };
  }

  TransitLog copyWith({
    int? id,
    int? scheduleId,
    DateTime? date,
    String? status,
  }) => TransitLog(
    id: id ?? this.id,
    scheduleId: scheduleId ?? this.scheduleId,
    date: date ?? this.date,
    status: status ?? this.status,
  );
  TransitLog copyWithCompanion(TransitLogsCompanion data) {
    return TransitLog(
      id: data.id.present ? data.id.value : this.id,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransitLog(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('date: $date, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduleId, date, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransitLog &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.date == this.date &&
          other.status == this.status);
}

class TransitLogsCompanion extends UpdateCompanion<TransitLog> {
  final Value<int> id;
  final Value<int> scheduleId;
  final Value<DateTime> date;
  final Value<String> status;
  const TransitLogsCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
  });
  TransitLogsCompanion.insert({
    this.id = const Value.absent(),
    required int scheduleId,
    required DateTime date,
    required String status,
  }) : scheduleId = Value(scheduleId),
       date = Value(date),
       status = Value(status);
  static Insertable<TransitLog> custom({
    Expression<int>? id,
    Expression<int>? scheduleId,
    Expression<DateTime>? date,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
    });
  }

  TransitLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? scheduleId,
    Value<DateTime>? date,
    Value<String>? status,
  }) {
    return TransitLogsCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransitLogsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('date: $date, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TransitSegmentLogsTable extends TransitSegmentLogs
    with TableInfo<$TransitSegmentLogsTable, TransitSegmentLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransitSegmentLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transitLogIdMeta = const VerificationMeta(
    'transitLogId',
  );
  @override
  late final GeneratedColumn<int> transitLogId = GeneratedColumn<int>(
    'transit_log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transit_logs (id)',
    ),
  );
  static const VerificationMeta _scheduleSegmentIdMeta = const VerificationMeta(
    'scheduleSegmentId',
  );
  @override
  late final GeneratedColumn<int> scheduleSegmentId = GeneratedColumn<int>(
    'schedule_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedule_segments (id)',
    ),
  );
  static const VerificationMeta _boardedAtMeta = const VerificationMeta(
    'boardedAt',
  );
  @override
  late final GeneratedColumn<DateTime> boardedAt = GeneratedColumn<DateTime>(
    'boarded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alightedAtMeta = const VerificationMeta(
    'alightedAt',
  );
  @override
  late final GeneratedColumn<DateTime> alightedAt = GeneratedColumn<DateTime>(
    'alighted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDurationMinutesMeta =
      const VerificationMeta('actualDurationMinutes');
  @override
  late final GeneratedColumn<int> actualDurationMinutes = GeneratedColumn<int>(
    'actual_duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transitLogId,
    scheduleSegmentId,
    boardedAt,
    alightedAt,
    actualDurationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transit_segment_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransitSegmentLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transit_log_id')) {
      context.handle(
        _transitLogIdMeta,
        transitLogId.isAcceptableOrUnknown(
          data['transit_log_id']!,
          _transitLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transitLogIdMeta);
    }
    if (data.containsKey('schedule_segment_id')) {
      context.handle(
        _scheduleSegmentIdMeta,
        scheduleSegmentId.isAcceptableOrUnknown(
          data['schedule_segment_id']!,
          _scheduleSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleSegmentIdMeta);
    }
    if (data.containsKey('boarded_at')) {
      context.handle(
        _boardedAtMeta,
        boardedAt.isAcceptableOrUnknown(data['boarded_at']!, _boardedAtMeta),
      );
    }
    if (data.containsKey('alighted_at')) {
      context.handle(
        _alightedAtMeta,
        alightedAt.isAcceptableOrUnknown(data['alighted_at']!, _alightedAtMeta),
      );
    }
    if (data.containsKey('actual_duration_minutes')) {
      context.handle(
        _actualDurationMinutesMeta,
        actualDurationMinutes.isAcceptableOrUnknown(
          data['actual_duration_minutes']!,
          _actualDurationMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransitSegmentLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransitSegmentLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transitLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transit_log_id'],
      )!,
      scheduleSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_segment_id'],
      )!,
      boardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}boarded_at'],
      ),
      alightedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}alighted_at'],
      ),
      actualDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_minutes'],
      ),
    );
  }

  @override
  $TransitSegmentLogsTable createAlias(String alias) {
    return $TransitSegmentLogsTable(attachedDatabase, alias);
  }
}

class TransitSegmentLog extends DataClass
    implements Insertable<TransitSegmentLog> {
  final int id;
  final int transitLogId;
  final int scheduleSegmentId;
  final DateTime? boardedAt;
  final DateTime? alightedAt;
  final int? actualDurationMinutes;
  const TransitSegmentLog({
    required this.id,
    required this.transitLogId,
    required this.scheduleSegmentId,
    this.boardedAt,
    this.alightedAt,
    this.actualDurationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transit_log_id'] = Variable<int>(transitLogId);
    map['schedule_segment_id'] = Variable<int>(scheduleSegmentId);
    if (!nullToAbsent || boardedAt != null) {
      map['boarded_at'] = Variable<DateTime>(boardedAt);
    }
    if (!nullToAbsent || alightedAt != null) {
      map['alighted_at'] = Variable<DateTime>(alightedAt);
    }
    if (!nullToAbsent || actualDurationMinutes != null) {
      map['actual_duration_minutes'] = Variable<int>(actualDurationMinutes);
    }
    return map;
  }

  TransitSegmentLogsCompanion toCompanion(bool nullToAbsent) {
    return TransitSegmentLogsCompanion(
      id: Value(id),
      transitLogId: Value(transitLogId),
      scheduleSegmentId: Value(scheduleSegmentId),
      boardedAt: boardedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(boardedAt),
      alightedAt: alightedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(alightedAt),
      actualDurationMinutes: actualDurationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationMinutes),
    );
  }

  factory TransitSegmentLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransitSegmentLog(
      id: serializer.fromJson<int>(json['id']),
      transitLogId: serializer.fromJson<int>(json['transitLogId']),
      scheduleSegmentId: serializer.fromJson<int>(json['scheduleSegmentId']),
      boardedAt: serializer.fromJson<DateTime?>(json['boardedAt']),
      alightedAt: serializer.fromJson<DateTime?>(json['alightedAt']),
      actualDurationMinutes: serializer.fromJson<int?>(
        json['actualDurationMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transitLogId': serializer.toJson<int>(transitLogId),
      'scheduleSegmentId': serializer.toJson<int>(scheduleSegmentId),
      'boardedAt': serializer.toJson<DateTime?>(boardedAt),
      'alightedAt': serializer.toJson<DateTime?>(alightedAt),
      'actualDurationMinutes': serializer.toJson<int?>(actualDurationMinutes),
    };
  }

  TransitSegmentLog copyWith({
    int? id,
    int? transitLogId,
    int? scheduleSegmentId,
    Value<DateTime?> boardedAt = const Value.absent(),
    Value<DateTime?> alightedAt = const Value.absent(),
    Value<int?> actualDurationMinutes = const Value.absent(),
  }) => TransitSegmentLog(
    id: id ?? this.id,
    transitLogId: transitLogId ?? this.transitLogId,
    scheduleSegmentId: scheduleSegmentId ?? this.scheduleSegmentId,
    boardedAt: boardedAt.present ? boardedAt.value : this.boardedAt,
    alightedAt: alightedAt.present ? alightedAt.value : this.alightedAt,
    actualDurationMinutes: actualDurationMinutes.present
        ? actualDurationMinutes.value
        : this.actualDurationMinutes,
  );
  TransitSegmentLog copyWithCompanion(TransitSegmentLogsCompanion data) {
    return TransitSegmentLog(
      id: data.id.present ? data.id.value : this.id,
      transitLogId: data.transitLogId.present
          ? data.transitLogId.value
          : this.transitLogId,
      scheduleSegmentId: data.scheduleSegmentId.present
          ? data.scheduleSegmentId.value
          : this.scheduleSegmentId,
      boardedAt: data.boardedAt.present ? data.boardedAt.value : this.boardedAt,
      alightedAt: data.alightedAt.present
          ? data.alightedAt.value
          : this.alightedAt,
      actualDurationMinutes: data.actualDurationMinutes.present
          ? data.actualDurationMinutes.value
          : this.actualDurationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransitSegmentLog(')
          ..write('id: $id, ')
          ..write('transitLogId: $transitLogId, ')
          ..write('scheduleSegmentId: $scheduleSegmentId, ')
          ..write('boardedAt: $boardedAt, ')
          ..write('alightedAt: $alightedAt, ')
          ..write('actualDurationMinutes: $actualDurationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transitLogId,
    scheduleSegmentId,
    boardedAt,
    alightedAt,
    actualDurationMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransitSegmentLog &&
          other.id == this.id &&
          other.transitLogId == this.transitLogId &&
          other.scheduleSegmentId == this.scheduleSegmentId &&
          other.boardedAt == this.boardedAt &&
          other.alightedAt == this.alightedAt &&
          other.actualDurationMinutes == this.actualDurationMinutes);
}

class TransitSegmentLogsCompanion extends UpdateCompanion<TransitSegmentLog> {
  final Value<int> id;
  final Value<int> transitLogId;
  final Value<int> scheduleSegmentId;
  final Value<DateTime?> boardedAt;
  final Value<DateTime?> alightedAt;
  final Value<int?> actualDurationMinutes;
  const TransitSegmentLogsCompanion({
    this.id = const Value.absent(),
    this.transitLogId = const Value.absent(),
    this.scheduleSegmentId = const Value.absent(),
    this.boardedAt = const Value.absent(),
    this.alightedAt = const Value.absent(),
    this.actualDurationMinutes = const Value.absent(),
  });
  TransitSegmentLogsCompanion.insert({
    this.id = const Value.absent(),
    required int transitLogId,
    required int scheduleSegmentId,
    this.boardedAt = const Value.absent(),
    this.alightedAt = const Value.absent(),
    this.actualDurationMinutes = const Value.absent(),
  }) : transitLogId = Value(transitLogId),
       scheduleSegmentId = Value(scheduleSegmentId);
  static Insertable<TransitSegmentLog> custom({
    Expression<int>? id,
    Expression<int>? transitLogId,
    Expression<int>? scheduleSegmentId,
    Expression<DateTime>? boardedAt,
    Expression<DateTime>? alightedAt,
    Expression<int>? actualDurationMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transitLogId != null) 'transit_log_id': transitLogId,
      if (scheduleSegmentId != null) 'schedule_segment_id': scheduleSegmentId,
      if (boardedAt != null) 'boarded_at': boardedAt,
      if (alightedAt != null) 'alighted_at': alightedAt,
      if (actualDurationMinutes != null)
        'actual_duration_minutes': actualDurationMinutes,
    });
  }

  TransitSegmentLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? transitLogId,
    Value<int>? scheduleSegmentId,
    Value<DateTime?>? boardedAt,
    Value<DateTime?>? alightedAt,
    Value<int?>? actualDurationMinutes,
  }) {
    return TransitSegmentLogsCompanion(
      id: id ?? this.id,
      transitLogId: transitLogId ?? this.transitLogId,
      scheduleSegmentId: scheduleSegmentId ?? this.scheduleSegmentId,
      boardedAt: boardedAt ?? this.boardedAt,
      alightedAt: alightedAt ?? this.alightedAt,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transitLogId.present) {
      map['transit_log_id'] = Variable<int>(transitLogId.value);
    }
    if (scheduleSegmentId.present) {
      map['schedule_segment_id'] = Variable<int>(scheduleSegmentId.value);
    }
    if (boardedAt.present) {
      map['boarded_at'] = Variable<DateTime>(boardedAt.value);
    }
    if (alightedAt.present) {
      map['alighted_at'] = Variable<DateTime>(alightedAt.value);
    }
    if (actualDurationMinutes.present) {
      map['actual_duration_minutes'] = Variable<int>(
        actualDurationMinutes.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransitSegmentLogsCompanion(')
          ..write('id: $id, ')
          ..write('transitLogId: $transitLogId, ')
          ..write('scheduleSegmentId: $scheduleSegmentId, ')
          ..write('boardedAt: $boardedAt, ')
          ..write('alightedAt: $alightedAt, ')
          ..write('actualDurationMinutes: $actualDurationMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $ScheduleSegmentsTable scheduleSegments = $ScheduleSegmentsTable(
    this,
  );
  late final $TransitLogsTable transitLogs = $TransitLogsTable(this);
  late final $TransitSegmentLogsTable transitSegmentLogs =
      $TransitSegmentLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schedules,
    scheduleSegments,
    transitLogs,
    transitSegmentLogs,
  ];
}

typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required String name,
  required int targetStartTime,
  required int targetArrivalTime,
  required String daysOfWeek,
  Value<bool> isActive,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> targetStartTime,
  Value<int> targetArrivalTime,
  Value<String> daysOfWeek,
  Value<bool> isActive,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScheduleSegmentsTable, List<ScheduleSegment>>
  _scheduleSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduleSegments,
    aliasName: 'schedules__id__schedule_segments__schedule_id',
  );

  $$ScheduleSegmentsTableProcessedTableManager get scheduleSegmentsRefs {
    final manager = $$ScheduleSegmentsTableTableManager(
      $_db,
      $_db.scheduleSegments,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduleSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransitLogsTable, List<TransitLog>>
  _transitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transitLogs,
    aliasName: 'schedules__id__transit_logs__schedule_id',
  );

  $$TransitLogsTableProcessedTableManager get transitLogsRefs {
    final manager = $$TransitLogsTableTableManager(
      $_db,
      $_db.transitLogs,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetStartTime => $composableBuilder(
    column: $table.targetStartTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetArrivalTime => $composableBuilder(
    column: $table.targetArrivalTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scheduleSegmentsRefs(
    Expression<bool> Function($$ScheduleSegmentsTableFilterComposer f) f,
  ) {
    final $$ScheduleSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleSegments,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transitLogsRefs(
    Expression<bool> Function($$TransitLogsTableFilterComposer f) f,
  ) {
    final $$TransitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transitLogs,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitLogsTableFilterComposer(
            $db: $db,
            $table: $db.transitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetStartTime => $composableBuilder(
    column: $table.targetStartTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetArrivalTime => $composableBuilder(
    column: $table.targetArrivalTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetStartTime => $composableBuilder(
    column: $table.targetStartTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetArrivalTime => $composableBuilder(
    column: $table.targetArrivalTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> scheduleSegmentsRefs<T extends Object>(
    Expression<T> Function($$ScheduleSegmentsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleSegments,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transitLogsRefs<T extends Object>(
    Expression<T> Function($$TransitLogsTableAnnotationComposer a) f,
  ) {
    final $$TransitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transitLogs,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.transitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          Schedule,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (Schedule, $$SchedulesTableReferences),
          Schedule,
          PrefetchHooks Function({
            bool scheduleSegmentsRefs,
            bool transitLogsRefs,
          })
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetStartTime = const Value.absent(),
                Value<int> targetArrivalTime = const Value.absent(),
                Value<String> daysOfWeek = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                name: name,
                targetStartTime: targetStartTime,
                targetArrivalTime: targetArrivalTime,
                daysOfWeek: daysOfWeek,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int targetStartTime,
                required int targetArrivalTime,
                required String daysOfWeek,
                Value<bool> isActive = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                name: name,
                targetStartTime: targetStartTime,
                targetArrivalTime: targetArrivalTime,
                daysOfWeek: daysOfWeek,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchedulesTable, Schedule>(table),
                  $$SchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleSegmentsRefs = false, transitLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleSegmentsRefs) db.scheduleSegments,
                    if (transitLogsRefs) db.transitLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleSegmentsRefs)
                        await $_getPrefetchedData<
                          Schedule,
                          $SchedulesTable,
                          ScheduleSegment
                        >(
                          currentTable: table,
                          referencedTable: $$SchedulesTableReferences
                              ._scheduleSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transitLogsRefs)
                        await $_getPrefetchedData<
                          Schedule,
                          $SchedulesTable,
                          TransitLog
                        >(
                          currentTable: table,
                          referencedTable: $$SchedulesTableReferences
                              ._transitLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).transitLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      Schedule,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (Schedule, $$SchedulesTableReferences),
      Schedule,
      PrefetchHooks Function({bool scheduleSegmentsRefs, bool transitLogsRefs})
    >;
typedef $$ScheduleSegmentsTableCreateCompanionBuilder =
    ScheduleSegmentsCompanion Function({
      Value<int> id,
      required int scheduleId,
      required String transportMode,
      Value<String> name,
      required int orderIndex,
      Value<int?> estimatedDurationMinutes,
    });
typedef $$ScheduleSegmentsTableUpdateCompanionBuilder =
    ScheduleSegmentsCompanion Function({
      Value<int> id,
      Value<int> scheduleId,
      Value<String> transportMode,
      Value<String> name,
      Value<int> orderIndex,
      Value<int?> estimatedDurationMinutes,
    });

final class $$ScheduleSegmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ScheduleSegmentsTable, ScheduleSegment> {
  $$ScheduleSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.schedules.createAlias('schedule_segments__schedule_id__schedules__id');

  $$SchedulesTableProcessedTableManager get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id')!;

    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransitSegmentLogsTable, List<TransitSegmentLog>>
  _transitSegmentLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transitSegmentLogs,
        aliasName:
            'schedule_segments__id__transit_segment_logs__schedule_segment_id',
      );

  $$TransitSegmentLogsTableProcessedTableManager get transitSegmentLogsRefs {
    final manager = $$TransitSegmentLogsTableTableManager(
      $_db,
      $_db.transitSegmentLogs,
    ).filter((f) => f.scheduleSegmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transitSegmentLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScheduleSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleSegmentsTable> {
  $$ScheduleSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transportMode => $composableBuilder(
    column: $table.transportMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$SchedulesTableFilterComposer get scheduleId {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transitSegmentLogsRefs(
    Expression<bool> Function($$TransitSegmentLogsTableFilterComposer f) f,
  ) {
    final $$TransitSegmentLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transitSegmentLogs,
      getReferencedColumn: (t) => t.scheduleSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitSegmentLogsTableFilterComposer(
            $db: $db,
            $table: $db.transitSegmentLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleSegmentsTable> {
  $$ScheduleSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transportMode => $composableBuilder(
    column: $table.transportMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchedulesTableOrderingComposer get scheduleId {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleSegmentsTable> {
  $$ScheduleSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transportMode => $composableBuilder(
    column: $table.transportMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => column,
  );

  $$SchedulesTableAnnotationComposer get scheduleId {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transitSegmentLogsRefs<T extends Object>(
    Expression<T> Function($$TransitSegmentLogsTableAnnotationComposer a) f,
  ) {
    final $$TransitSegmentLogsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transitSegmentLogs,
          getReferencedColumn: (t) => t.scheduleSegmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransitSegmentLogsTableAnnotationComposer(
                $db: $db,
                $table: $db.transitSegmentLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScheduleSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleSegmentsTable,
          ScheduleSegment,
          $$ScheduleSegmentsTableFilterComposer,
          $$ScheduleSegmentsTableOrderingComposer,
          $$ScheduleSegmentsTableAnnotationComposer,
          $$ScheduleSegmentsTableCreateCompanionBuilder,
          $$ScheduleSegmentsTableUpdateCompanionBuilder,
          (ScheduleSegment, $$ScheduleSegmentsTableReferences),
          ScheduleSegment,
          PrefetchHooks Function({bool scheduleId, bool transitSegmentLogsRefs})
        > {
  $$ScheduleSegmentsTableTableManager(
    _$AppDatabase db,
    $ScheduleSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scheduleId = const Value.absent(),
                Value<String> transportMode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int?> estimatedDurationMinutes = const Value.absent(),
              }) => ScheduleSegmentsCompanion(
                id: id,
                scheduleId: scheduleId,
                transportMode: transportMode,
                name: name,
                orderIndex: orderIndex,
                estimatedDurationMinutes: estimatedDurationMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scheduleId,
                required String transportMode,
                Value<String> name = const Value.absent(),
                required int orderIndex,
                Value<int?> estimatedDurationMinutes = const Value.absent(),
              }) => ScheduleSegmentsCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                transportMode: transportMode,
                name: name,
                orderIndex: orderIndex,
                estimatedDurationMinutes: estimatedDurationMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduleSegmentsTable, ScheduleSegment>(table),
                  $$ScheduleSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleId = false, transitSegmentLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transitSegmentLogsRefs) db.transitSegmentLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scheduleId,
                            referencedTable: $$ScheduleSegmentsTableReferences
                                ._scheduleIdTable(db),
                            referencedColumn: $$ScheduleSegmentsTableReferences
                                ._scheduleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transitSegmentLogsRefs)
                        await $_getPrefetchedData<
                          ScheduleSegment,
                          $ScheduleSegmentsTable,
                          TransitSegmentLog
                        >(
                          currentTable: table,
                          referencedTable: $$ScheduleSegmentsTableReferences
                              ._transitSegmentLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScheduleSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).transitSegmentLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleSegmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScheduleSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleSegmentsTable,
      ScheduleSegment,
      $$ScheduleSegmentsTableFilterComposer,
      $$ScheduleSegmentsTableOrderingComposer,
      $$ScheduleSegmentsTableAnnotationComposer,
      $$ScheduleSegmentsTableCreateCompanionBuilder,
      $$ScheduleSegmentsTableUpdateCompanionBuilder,
      (ScheduleSegment, $$ScheduleSegmentsTableReferences),
      ScheduleSegment,
      PrefetchHooks Function({bool scheduleId, bool transitSegmentLogsRefs})
    >;
typedef $$TransitLogsTableCreateCompanionBuilder =
    TransitLogsCompanion Function({
      Value<int> id,
      required int scheduleId,
      required DateTime date,
      required String status,
    });
typedef $$TransitLogsTableUpdateCompanionBuilder =
    TransitLogsCompanion Function({
      Value<int> id,
      Value<int> scheduleId,
      Value<DateTime> date,
      Value<String> status,
    });

final class $$TransitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TransitLogsTable, TransitLog> {
  $$TransitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.schedules.createAlias('transit_logs__schedule_id__schedules__id');

  $$SchedulesTableProcessedTableManager get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id')!;

    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransitSegmentLogsTable, List<TransitSegmentLog>>
  _transitSegmentLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transitSegmentLogs,
        aliasName: 'transit_logs__id__transit_segment_logs__transit_log_id',
      );

  $$TransitSegmentLogsTableProcessedTableManager get transitSegmentLogsRefs {
    final manager = $$TransitSegmentLogsTableTableManager(
      $_db,
      $_db.transitSegmentLogs,
    ).filter((f) => f.transitLogId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transitSegmentLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TransitLogsTable> {
  $$TransitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$SchedulesTableFilterComposer get scheduleId {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transitSegmentLogsRefs(
    Expression<bool> Function($$TransitSegmentLogsTableFilterComposer f) f,
  ) {
    final $$TransitSegmentLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transitSegmentLogs,
      getReferencedColumn: (t) => t.transitLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitSegmentLogsTableFilterComposer(
            $db: $db,
            $table: $db.transitSegmentLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransitLogsTable> {
  $$TransitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchedulesTableOrderingComposer get scheduleId {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransitLogsTable> {
  $$TransitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$SchedulesTableAnnotationComposer get scheduleId {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transitSegmentLogsRefs<T extends Object>(
    Expression<T> Function($$TransitSegmentLogsTableAnnotationComposer a) f,
  ) {
    final $$TransitSegmentLogsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transitSegmentLogs,
          getReferencedColumn: (t) => t.transitLogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransitSegmentLogsTableAnnotationComposer(
                $db: $db,
                $table: $db.transitSegmentLogs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransitLogsTable,
          TransitLog,
          $$TransitLogsTableFilterComposer,
          $$TransitLogsTableOrderingComposer,
          $$TransitLogsTableAnnotationComposer,
          $$TransitLogsTableCreateCompanionBuilder,
          $$TransitLogsTableUpdateCompanionBuilder,
          (TransitLog, $$TransitLogsTableReferences),
          TransitLog,
          PrefetchHooks Function({bool scheduleId, bool transitSegmentLogsRefs})
        > {
  $$TransitLogsTableTableManager(_$AppDatabase db, $TransitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scheduleId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => TransitLogsCompanion(
                id: id,
                scheduleId: scheduleId,
                date: date,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scheduleId,
                required DateTime date,
                required String status,
              }) => TransitLogsCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                date: date,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransitLogsTable, TransitLog>(table),
                  $$TransitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleId = false, transitSegmentLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transitSegmentLogsRefs) db.transitSegmentLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scheduleId,
                            referencedTable: $$TransitLogsTableReferences
                                ._scheduleIdTable(db),
                            referencedColumn: $$TransitLogsTableReferences
                                ._scheduleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transitSegmentLogsRefs)
                        await $_getPrefetchedData<
                          TransitLog,
                          $TransitLogsTable,
                          TransitSegmentLog
                        >(
                          currentTable: table,
                          referencedTable: $$TransitLogsTableReferences
                              ._transitSegmentLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransitLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).transitSegmentLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transitLogId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransitLogsTable,
      TransitLog,
      $$TransitLogsTableFilterComposer,
      $$TransitLogsTableOrderingComposer,
      $$TransitLogsTableAnnotationComposer,
      $$TransitLogsTableCreateCompanionBuilder,
      $$TransitLogsTableUpdateCompanionBuilder,
      (TransitLog, $$TransitLogsTableReferences),
      TransitLog,
      PrefetchHooks Function({bool scheduleId, bool transitSegmentLogsRefs})
    >;
typedef $$TransitSegmentLogsTableCreateCompanionBuilder =
    TransitSegmentLogsCompanion Function({
      Value<int> id,
      required int transitLogId,
      required int scheduleSegmentId,
      Value<DateTime?> boardedAt,
      Value<DateTime?> alightedAt,
      Value<int?> actualDurationMinutes,
    });
typedef $$TransitSegmentLogsTableUpdateCompanionBuilder =
    TransitSegmentLogsCompanion Function({
      Value<int> id,
      Value<int> transitLogId,
      Value<int> scheduleSegmentId,
      Value<DateTime?> boardedAt,
      Value<DateTime?> alightedAt,
      Value<int?> actualDurationMinutes,
    });

final class $$TransitSegmentLogsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransitSegmentLogsTable,
          TransitSegmentLog
        > {
  $$TransitSegmentLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransitLogsTable _transitLogIdTable(_$AppDatabase db) => db
      .transitLogs
      .createAlias('transit_segment_logs__transit_log_id__transit_logs__id');

  $$TransitLogsTableProcessedTableManager get transitLogId {
    final $_column = $_itemColumn<int>('transit_log_id')!;

    final manager = $$TransitLogsTableTableManager(
      $_db,
      $_db.transitLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transitLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScheduleSegmentsTable _scheduleSegmentIdTable(_$AppDatabase db) =>
      db.scheduleSegments.createAlias(
        'transit_segment_logs__schedule_segment_id__schedule_segments__id',
      );

  $$ScheduleSegmentsTableProcessedTableManager get scheduleSegmentId {
    final $_column = $_itemColumn<int>('schedule_segment_id')!;

    final manager = $$ScheduleSegmentsTableTableManager(
      $_db,
      $_db.scheduleSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleSegmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransitSegmentLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TransitSegmentLogsTable> {
  $$TransitSegmentLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get boardedAt => $composableBuilder(
    column: $table.boardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get alightedAt => $composableBuilder(
    column: $table.alightedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$TransitLogsTableFilterComposer get transitLogId {
    final $$TransitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transitLogId,
      referencedTable: $db.transitLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitLogsTableFilterComposer(
            $db: $db,
            $table: $db.transitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleSegmentsTableFilterComposer get scheduleSegmentId {
    final $$ScheduleSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleSegmentId,
      referencedTable: $db.scheduleSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransitSegmentLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransitSegmentLogsTable> {
  $$TransitSegmentLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get boardedAt => $composableBuilder(
    column: $table.boardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get alightedAt => $composableBuilder(
    column: $table.alightedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransitLogsTableOrderingComposer get transitLogId {
    final $$TransitLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transitLogId,
      referencedTable: $db.transitLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitLogsTableOrderingComposer(
            $db: $db,
            $table: $db.transitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleSegmentsTableOrderingComposer get scheduleSegmentId {
    final $$ScheduleSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleSegmentId,
      referencedTable: $db.scheduleSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.scheduleSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransitSegmentLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransitSegmentLogsTable> {
  $$TransitSegmentLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get boardedAt =>
      $composableBuilder(column: $table.boardedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get alightedAt => $composableBuilder(
    column: $table.alightedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationMinutes => $composableBuilder(
    column: $table.actualDurationMinutes,
    builder: (column) => column,
  );

  $$TransitLogsTableAnnotationComposer get transitLogId {
    final $$TransitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transitLogId,
      referencedTable: $db.transitLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.transitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleSegmentsTableAnnotationComposer get scheduleSegmentId {
    final $$ScheduleSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleSegmentId,
      referencedTable: $db.scheduleSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransitSegmentLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransitSegmentLogsTable,
          TransitSegmentLog,
          $$TransitSegmentLogsTableFilterComposer,
          $$TransitSegmentLogsTableOrderingComposer,
          $$TransitSegmentLogsTableAnnotationComposer,
          $$TransitSegmentLogsTableCreateCompanionBuilder,
          $$TransitSegmentLogsTableUpdateCompanionBuilder,
          (TransitSegmentLog, $$TransitSegmentLogsTableReferences),
          TransitSegmentLog,
          PrefetchHooks Function({bool transitLogId, bool scheduleSegmentId})
        > {
  $$TransitSegmentLogsTableTableManager(
    _$AppDatabase db,
    $TransitSegmentLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransitSegmentLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransitSegmentLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransitSegmentLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transitLogId = const Value.absent(),
                Value<int> scheduleSegmentId = const Value.absent(),
                Value<DateTime?> boardedAt = const Value.absent(),
                Value<DateTime?> alightedAt = const Value.absent(),
                Value<int?> actualDurationMinutes = const Value.absent(),
              }) => TransitSegmentLogsCompanion(
                id: id,
                transitLogId: transitLogId,
                scheduleSegmentId: scheduleSegmentId,
                boardedAt: boardedAt,
                alightedAt: alightedAt,
                actualDurationMinutes: actualDurationMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transitLogId,
                required int scheduleSegmentId,
                Value<DateTime?> boardedAt = const Value.absent(),
                Value<DateTime?> alightedAt = const Value.absent(),
                Value<int?> actualDurationMinutes = const Value.absent(),
              }) => TransitSegmentLogsCompanion.insert(
                id: id,
                transitLogId: transitLogId,
                scheduleSegmentId: scheduleSegmentId,
                boardedAt: boardedAt,
                alightedAt: alightedAt,
                actualDurationMinutes: actualDurationMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransitSegmentLogsTable, TransitSegmentLog>(
                    table,
                  ),
                  $$TransitSegmentLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transitLogId = false, scheduleSegmentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (transitLogId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.transitLogId,
                            referencedTable: $$TransitSegmentLogsTableReferences
                                ._transitLogIdTable(db),
                            referencedColumn:
                                $$TransitSegmentLogsTableReferences
                                    ._transitLogIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (scheduleSegmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scheduleSegmentId,
                            referencedTable: $$TransitSegmentLogsTableReferences
                                ._scheduleSegmentIdTable(db),
                            referencedColumn:
                                $$TransitSegmentLogsTableReferences
                                    ._scheduleSegmentIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransitSegmentLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransitSegmentLogsTable,
      TransitSegmentLog,
      $$TransitSegmentLogsTableFilterComposer,
      $$TransitSegmentLogsTableOrderingComposer,
      $$TransitSegmentLogsTableAnnotationComposer,
      $$TransitSegmentLogsTableCreateCompanionBuilder,
      $$TransitSegmentLogsTableUpdateCompanionBuilder,
      (TransitSegmentLog, $$TransitSegmentLogsTableReferences),
      TransitSegmentLog,
      PrefetchHooks Function({bool transitLogId, bool scheduleSegmentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$ScheduleSegmentsTableTableManager get scheduleSegments =>
      $$ScheduleSegmentsTableTableManager(_db, _db.scheduleSegments);
  $$TransitLogsTableTableManager get transitLogs =>
      $$TransitLogsTableTableManager(_db, _db.transitLogs);
  $$TransitSegmentLogsTableTableManager get transitSegmentLogs =>
      $$TransitSegmentLogsTableTableManager(_db, _db.transitSegmentLogs);
}
