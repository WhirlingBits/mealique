// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_storage.dart';

// ignore_for_file: type=lint
class $CachedRecipesTable extends CachedRecipes
    with TableInfo<$CachedRecipesTable, CachedRecipeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
      'slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonDataMeta =
      const VerificationMeta('jsonData');
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
      'json_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, slug, jsonData, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recipes';
  @override
  VerificationContext validateIntegrity(Insertable<CachedRecipeEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
          _slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(_jsonDataMeta,
          jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta));
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRecipeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecipeEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      jsonData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_data'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedRecipesTable createAlias(String alias) {
    return $CachedRecipesTable(attachedDatabase, alias);
  }
}

class CachedRecipeEntry extends DataClass
    implements Insertable<CachedRecipeEntry> {
  final String id;
  final String slug;
  final String jsonData;
  final String updatedAt;
  const CachedRecipeEntry(
      {required this.id,
      required this.slug,
      required this.jsonData,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['json_data'] = Variable<String>(jsonData);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CachedRecipesCompanion toCompanion(bool nullToAbsent) {
    return CachedRecipesCompanion(
      id: Value(id),
      slug: Value(slug),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedRecipeEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecipeEntry(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'jsonData': serializer.toJson<String>(jsonData),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CachedRecipeEntry copyWith(
          {String? id, String? slug, String? jsonData, String? updatedAt}) =>
      CachedRecipeEntry(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        jsonData: jsonData ?? this.jsonData,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedRecipeEntry copyWithCompanion(CachedRecipesCompanion data) {
    return CachedRecipeEntry(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipeEntry(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('jsonData: $jsonData, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, slug, jsonData, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecipeEntry &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.jsonData == this.jsonData &&
          other.updatedAt == this.updatedAt);
}

class CachedRecipesCompanion extends UpdateCompanion<CachedRecipeEntry> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> jsonData;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const CachedRecipesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecipesCompanion.insert({
    required String id,
    required String slug,
    required String jsonData,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        slug = Value(slug),
        jsonData = Value(jsonData);
  static Insertable<CachedRecipeEntry> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? jsonData,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (jsonData != null) 'json_data': jsonData,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecipesCompanion copyWith(
      {Value<String>? id,
      Value<String>? slug,
      Value<String>? jsonData,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return CachedRecipesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      jsonData: jsonData ?? this.jsonData,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecipesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('jsonData: $jsonData, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedFoodsTable extends CachedFoods
    with TableInfo<$CachedFoodsTable, CachedFoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonDataMeta =
      const VerificationMeta('jsonData');
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
      'json_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, jsonData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_foods';
  @override
  VerificationContext validateIntegrity(Insertable<CachedFoodEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(_jsonDataMeta,
          jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta));
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFoodEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      jsonData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_data'])!,
    );
  }

  @override
  $CachedFoodsTable createAlias(String alias) {
    return $CachedFoodsTable(attachedDatabase, alias);
  }
}

class CachedFoodEntry extends DataClass implements Insertable<CachedFoodEntry> {
  final String id;
  final String jsonData;
  const CachedFoodEntry({required this.id, required this.jsonData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json_data'] = Variable<String>(jsonData);
    return map;
  }

  CachedFoodsCompanion toCompanion(bool nullToAbsent) {
    return CachedFoodsCompanion(
      id: Value(id),
      jsonData: Value(jsonData),
    );
  }

  factory CachedFoodEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFoodEntry(
      id: serializer.fromJson<String>(json['id']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jsonData': serializer.toJson<String>(jsonData),
    };
  }

  CachedFoodEntry copyWith({String? id, String? jsonData}) => CachedFoodEntry(
        id: id ?? this.id,
        jsonData: jsonData ?? this.jsonData,
      );
  CachedFoodEntry copyWithCompanion(CachedFoodsCompanion data) {
    return CachedFoodEntry(
      id: data.id.present ? data.id.value : this.id,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFoodEntry(')
          ..write('id: $id, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jsonData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFoodEntry &&
          other.id == this.id &&
          other.jsonData == this.jsonData);
}

class CachedFoodsCompanion extends UpdateCompanion<CachedFoodEntry> {
  final Value<String> id;
  final Value<String> jsonData;
  final Value<int> rowid;
  const CachedFoodsCompanion({
    this.id = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFoodsCompanion.insert({
    required String id,
    required String jsonData,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        jsonData = Value(jsonData);
  static Insertable<CachedFoodEntry> custom({
    Expression<String>? id,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFoodsCompanion copyWith(
      {Value<String>? id, Value<String>? jsonData, Value<int>? rowid}) {
    return CachedFoodsCompanion(
      id: id ?? this.id,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFoodsCompanion(')
          ..write('id: $id, ')
          ..write('jsonData: $jsonData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedUnitsTable extends CachedUnits
    with TableInfo<$CachedUnitsTable, CachedUnitEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonDataMeta =
      const VerificationMeta('jsonData');
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
      'json_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, jsonData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_units';
  @override
  VerificationContext validateIntegrity(Insertable<CachedUnitEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(_jsonDataMeta,
          jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta));
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUnitEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUnitEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      jsonData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_data'])!,
    );
  }

  @override
  $CachedUnitsTable createAlias(String alias) {
    return $CachedUnitsTable(attachedDatabase, alias);
  }
}

class CachedUnitEntry extends DataClass implements Insertable<CachedUnitEntry> {
  final String id;
  final String jsonData;
  const CachedUnitEntry({required this.id, required this.jsonData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json_data'] = Variable<String>(jsonData);
    return map;
  }

  CachedUnitsCompanion toCompanion(bool nullToAbsent) {
    return CachedUnitsCompanion(
      id: Value(id),
      jsonData: Value(jsonData),
    );
  }

  factory CachedUnitEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUnitEntry(
      id: serializer.fromJson<String>(json['id']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jsonData': serializer.toJson<String>(jsonData),
    };
  }

  CachedUnitEntry copyWith({String? id, String? jsonData}) => CachedUnitEntry(
        id: id ?? this.id,
        jsonData: jsonData ?? this.jsonData,
      );
  CachedUnitEntry copyWithCompanion(CachedUnitsCompanion data) {
    return CachedUnitEntry(
      id: data.id.present ? data.id.value : this.id,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUnitEntry(')
          ..write('id: $id, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jsonData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUnitEntry &&
          other.id == this.id &&
          other.jsonData == this.jsonData);
}

class CachedUnitsCompanion extends UpdateCompanion<CachedUnitEntry> {
  final Value<String> id;
  final Value<String> jsonData;
  final Value<int> rowid;
  const CachedUnitsCompanion({
    this.id = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUnitsCompanion.insert({
    required String id,
    required String jsonData,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        jsonData = Value(jsonData);
  static Insertable<CachedUnitEntry> custom({
    Expression<String>? id,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUnitsCompanion copyWith(
      {Value<String>? id, Value<String>? jsonData, Value<int>? rowid}) {
    return CachedUnitsCompanion(
      id: id ?? this.id,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUnitsCompanion(')
          ..write('id: $id, ')
          ..write('jsonData: $jsonData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$RecipeDatabase extends GeneratedDatabase {
  _$RecipeDatabase(QueryExecutor e) : super(e);
  $RecipeDatabaseManager get managers => $RecipeDatabaseManager(this);
  late final $CachedRecipesTable cachedRecipes = $CachedRecipesTable(this);
  late final $CachedFoodsTable cachedFoods = $CachedFoodsTable(this);
  late final $CachedUnitsTable cachedUnits = $CachedUnitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedRecipes, cachedFoods, cachedUnits];
}

typedef $$CachedRecipesTableCreateCompanionBuilder = CachedRecipesCompanion
    Function({
  required String id,
  required String slug,
  required String jsonData,
  Value<String> updatedAt,
  Value<int> rowid,
});
typedef $$CachedRecipesTableUpdateCompanionBuilder = CachedRecipesCompanion
    Function({
  Value<String> id,
  Value<String> slug,
  Value<String> jsonData,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$CachedRecipesTableFilterComposer
    extends Composer<_$RecipeDatabase, $CachedRecipesTable> {
  $$CachedRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jsonData => $composableBuilder(
      column: $table.jsonData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedRecipesTableOrderingComposer
    extends Composer<_$RecipeDatabase, $CachedRecipesTable> {
  $$CachedRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jsonData => $composableBuilder(
      column: $table.jsonData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedRecipesTableAnnotationComposer
    extends Composer<_$RecipeDatabase, $CachedRecipesTable> {
  $$CachedRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedRecipesTableTableManager extends RootTableManager<
    _$RecipeDatabase,
    $CachedRecipesTable,
    CachedRecipeEntry,
    $$CachedRecipesTableFilterComposer,
    $$CachedRecipesTableOrderingComposer,
    $$CachedRecipesTableAnnotationComposer,
    $$CachedRecipesTableCreateCompanionBuilder,
    $$CachedRecipesTableUpdateCompanionBuilder,
    (
      CachedRecipeEntry,
      BaseReferences<_$RecipeDatabase, $CachedRecipesTable, CachedRecipeEntry>
    ),
    CachedRecipeEntry,
    PrefetchHooks Function()> {
  $$CachedRecipesTableTableManager(
      _$RecipeDatabase db, $CachedRecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> slug = const Value.absent(),
            Value<String> jsonData = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipesCompanion(
            id: id,
            slug: slug,
            jsonData: jsonData,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String slug,
            required String jsonData,
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecipesCompanion.insert(
            id: id,
            slug: slug,
            jsonData: jsonData,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecipesTableProcessedTableManager = ProcessedTableManager<
    _$RecipeDatabase,
    $CachedRecipesTable,
    CachedRecipeEntry,
    $$CachedRecipesTableFilterComposer,
    $$CachedRecipesTableOrderingComposer,
    $$CachedRecipesTableAnnotationComposer,
    $$CachedRecipesTableCreateCompanionBuilder,
    $$CachedRecipesTableUpdateCompanionBuilder,
    (
      CachedRecipeEntry,
      BaseReferences<_$RecipeDatabase, $CachedRecipesTable, CachedRecipeEntry>
    ),
    CachedRecipeEntry,
    PrefetchHooks Function()>;
typedef $$CachedFoodsTableCreateCompanionBuilder = CachedFoodsCompanion
    Function({
  required String id,
  required String jsonData,
  Value<int> rowid,
});
typedef $$CachedFoodsTableUpdateCompanionBuilder = CachedFoodsCompanion
    Function({
  Value<String> id,
  Value<String> jsonData,
  Value<int> rowid,
});

class $$CachedFoodsTableFilterComposer
    extends Composer<_$RecipeDatabase, $CachedFoodsTable> {
  $$CachedFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jsonData => $composableBuilder(
      column: $table.jsonData, builder: (column) => ColumnFilters(column));
}

class $$CachedFoodsTableOrderingComposer
    extends Composer<_$RecipeDatabase, $CachedFoodsTable> {
  $$CachedFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jsonData => $composableBuilder(
      column: $table.jsonData, builder: (column) => ColumnOrderings(column));
}

class $$CachedFoodsTableAnnotationComposer
    extends Composer<_$RecipeDatabase, $CachedFoodsTable> {
  $$CachedFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);
}

class $$CachedFoodsTableTableManager extends RootTableManager<
    _$RecipeDatabase,
    $CachedFoodsTable,
    CachedFoodEntry,
    $$CachedFoodsTableFilterComposer,
    $$CachedFoodsTableOrderingComposer,
    $$CachedFoodsTableAnnotationComposer,
    $$CachedFoodsTableCreateCompanionBuilder,
    $$CachedFoodsTableUpdateCompanionBuilder,
    (
      CachedFoodEntry,
      BaseReferences<_$RecipeDatabase, $CachedFoodsTable, CachedFoodEntry>
    ),
    CachedFoodEntry,
    PrefetchHooks Function()> {
  $$CachedFoodsTableTableManager(_$RecipeDatabase db, $CachedFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> jsonData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedFoodsCompanion(
            id: id,
            jsonData: jsonData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String jsonData,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedFoodsCompanion.insert(
            id: id,
            jsonData: jsonData,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedFoodsTableProcessedTableManager = ProcessedTableManager<
    _$RecipeDatabase,
    $CachedFoodsTable,
    CachedFoodEntry,
    $$CachedFoodsTableFilterComposer,
    $$CachedFoodsTableOrderingComposer,
    $$CachedFoodsTableAnnotationComposer,
    $$CachedFoodsTableCreateCompanionBuilder,
    $$CachedFoodsTableUpdateCompanionBuilder,
    (
      CachedFoodEntry,
      BaseReferences<_$RecipeDatabase, $CachedFoodsTable, CachedFoodEntry>
    ),
    CachedFoodEntry,
    PrefetchHooks Function()>;
typedef $$CachedUnitsTableCreateCompanionBuilder = CachedUnitsCompanion
    Function({
  required String id,
  required String jsonData,
  Value<int> rowid,
});
typedef $$CachedUnitsTableUpdateCompanionBuilder = CachedUnitsCompanion
    Function({
  Value<String> id,
  Value<String> jsonData,
  Value<int> rowid,
});

class $$CachedUnitsTableFilterComposer
    extends Composer<_$RecipeDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jsonData => $composableBuilder(
      column: $table.jsonData, builder: (column) => ColumnFilters(column));
}

class $$CachedUnitsTableOrderingComposer
    extends Composer<_$RecipeDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jsonData => $composableBuilder(
      column: $table.jsonData, builder: (column) => ColumnOrderings(column));
}

class $$CachedUnitsTableAnnotationComposer
    extends Composer<_$RecipeDatabase, $CachedUnitsTable> {
  $$CachedUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);
}

class $$CachedUnitsTableTableManager extends RootTableManager<
    _$RecipeDatabase,
    $CachedUnitsTable,
    CachedUnitEntry,
    $$CachedUnitsTableFilterComposer,
    $$CachedUnitsTableOrderingComposer,
    $$CachedUnitsTableAnnotationComposer,
    $$CachedUnitsTableCreateCompanionBuilder,
    $$CachedUnitsTableUpdateCompanionBuilder,
    (
      CachedUnitEntry,
      BaseReferences<_$RecipeDatabase, $CachedUnitsTable, CachedUnitEntry>
    ),
    CachedUnitEntry,
    PrefetchHooks Function()> {
  $$CachedUnitsTableTableManager(_$RecipeDatabase db, $CachedUnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> jsonData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedUnitsCompanion(
            id: id,
            jsonData: jsonData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String jsonData,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedUnitsCompanion.insert(
            id: id,
            jsonData: jsonData,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedUnitsTableProcessedTableManager = ProcessedTableManager<
    _$RecipeDatabase,
    $CachedUnitsTable,
    CachedUnitEntry,
    $$CachedUnitsTableFilterComposer,
    $$CachedUnitsTableOrderingComposer,
    $$CachedUnitsTableAnnotationComposer,
    $$CachedUnitsTableCreateCompanionBuilder,
    $$CachedUnitsTableUpdateCompanionBuilder,
    (
      CachedUnitEntry,
      BaseReferences<_$RecipeDatabase, $CachedUnitsTable, CachedUnitEntry>
    ),
    CachedUnitEntry,
    PrefetchHooks Function()>;

class $RecipeDatabaseManager {
  final _$RecipeDatabase _db;
  $RecipeDatabaseManager(this._db);
  $$CachedRecipesTableTableManager get cachedRecipes =>
      $$CachedRecipesTableTableManager(_db, _db.cachedRecipes);
  $$CachedFoodsTableTableManager get cachedFoods =>
      $$CachedFoodsTableTableManager(_db, _db.cachedFoods);
  $$CachedUnitsTableTableManager get cachedUnits =>
      $$CachedUnitsTableTableManager(_db, _db.cachedUnits);
}
