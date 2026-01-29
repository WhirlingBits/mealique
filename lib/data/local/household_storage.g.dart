// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_storage.dart';

// ignore_for_file: type=lint
class $CookbooksTable extends Cookbooks
    with TableInfo<$CookbooksTable, CookbookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CookbooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
      'slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _publicMeta = const VerificationMeta('public');
  @override
  late final GeneratedColumn<bool> public = GeneratedColumn<bool>(
      'public', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("public" IN (0, 1))'));
  static const VerificationMeta _queryFilterStringMeta =
      const VerificationMeta('queryFilterString');
  @override
  late final GeneratedColumn<String> queryFilterString =
      GeneratedColumn<String>('query_filter_string', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<QueryFilter, String> queryFilter =
      GeneratedColumn<String>('query_filter', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<QueryFilter>($CookbooksTable.$converterqueryFilter);
  @override
  late final GeneratedColumnWithTypeConverter<Household, String> household =
      GeneratedColumn<String>('household', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Household>($CookbooksTable.$converterhousehold);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        slug,
        position,
        public,
        queryFilterString,
        groupId,
        householdId,
        queryFilter,
        household
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cookbooks';
  @override
  VerificationContext validateIntegrity(Insertable<CookbookEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
          _slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('public')) {
      context.handle(_publicMeta,
          public.isAcceptableOrUnknown(data['public']!, _publicMeta));
    } else if (isInserting) {
      context.missing(_publicMeta);
    }
    if (data.containsKey('query_filter_string')) {
      context.handle(
          _queryFilterStringMeta,
          queryFilterString.isAcceptableOrUnknown(
              data['query_filter_string']!, _queryFilterStringMeta));
    } else if (isInserting) {
      context.missing(_queryFilterStringMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CookbookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CookbookEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      slug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      public: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}public'])!,
      queryFilterString: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}query_filter_string'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      queryFilter: $CookbooksTable.$converterqueryFilter.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}query_filter'])!),
      household: $CookbooksTable.$converterhousehold.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household'])!),
    );
  }

  @override
  $CookbooksTable createAlias(String alias) {
    return $CookbooksTable(attachedDatabase, alias);
  }

  static TypeConverter<QueryFilter, String> $converterqueryFilter =
      const QueryFilterConverter();
  static TypeConverter<Household, String> $converterhousehold =
      const HouseholdConverter();
}

class CookbookEntry extends DataClass implements Insertable<CookbookEntry> {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final int position;
  final bool public;
  final String queryFilterString;
  final String groupId;
  final String householdId;
  final QueryFilter queryFilter;
  final Household household;
  const CookbookEntry(
      {required this.id,
      required this.name,
      this.description,
      required this.slug,
      required this.position,
      required this.public,
      required this.queryFilterString,
      required this.groupId,
      required this.householdId,
      required this.queryFilter,
      required this.household});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['slug'] = Variable<String>(slug);
    map['position'] = Variable<int>(position);
    map['public'] = Variable<bool>(public);
    map['query_filter_string'] = Variable<String>(queryFilterString);
    map['group_id'] = Variable<String>(groupId);
    map['household_id'] = Variable<String>(householdId);
    {
      map['query_filter'] = Variable<String>(
          $CookbooksTable.$converterqueryFilter.toSql(queryFilter));
    }
    {
      map['household'] = Variable<String>(
          $CookbooksTable.$converterhousehold.toSql(household));
    }
    return map;
  }

  CookbooksCompanion toCompanion(bool nullToAbsent) {
    return CookbooksCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      slug: Value(slug),
      position: Value(position),
      public: Value(public),
      queryFilterString: Value(queryFilterString),
      groupId: Value(groupId),
      householdId: Value(householdId),
      queryFilter: Value(queryFilter),
      household: Value(household),
    );
  }

  factory CookbookEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CookbookEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      slug: serializer.fromJson<String>(json['slug']),
      position: serializer.fromJson<int>(json['position']),
      public: serializer.fromJson<bool>(json['public']),
      queryFilterString: serializer.fromJson<String>(json['queryFilterString']),
      groupId: serializer.fromJson<String>(json['groupId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      queryFilter: serializer.fromJson<QueryFilter>(json['queryFilter']),
      household: serializer.fromJson<Household>(json['household']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'slug': serializer.toJson<String>(slug),
      'position': serializer.toJson<int>(position),
      'public': serializer.toJson<bool>(public),
      'queryFilterString': serializer.toJson<String>(queryFilterString),
      'groupId': serializer.toJson<String>(groupId),
      'householdId': serializer.toJson<String>(householdId),
      'queryFilter': serializer.toJson<QueryFilter>(queryFilter),
      'household': serializer.toJson<Household>(household),
    };
  }

  CookbookEntry copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? slug,
          int? position,
          bool? public,
          String? queryFilterString,
          String? groupId,
          String? householdId,
          QueryFilter? queryFilter,
          Household? household}) =>
      CookbookEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        slug: slug ?? this.slug,
        position: position ?? this.position,
        public: public ?? this.public,
        queryFilterString: queryFilterString ?? this.queryFilterString,
        groupId: groupId ?? this.groupId,
        householdId: householdId ?? this.householdId,
        queryFilter: queryFilter ?? this.queryFilter,
        household: household ?? this.household,
      );
  CookbookEntry copyWithCompanion(CookbooksCompanion data) {
    return CookbookEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      slug: data.slug.present ? data.slug.value : this.slug,
      position: data.position.present ? data.position.value : this.position,
      public: data.public.present ? data.public.value : this.public,
      queryFilterString: data.queryFilterString.present
          ? data.queryFilterString.value
          : this.queryFilterString,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      queryFilter:
          data.queryFilter.present ? data.queryFilter.value : this.queryFilter,
      household: data.household.present ? data.household.value : this.household,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CookbookEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('slug: $slug, ')
          ..write('position: $position, ')
          ..write('public: $public, ')
          ..write('queryFilterString: $queryFilterString, ')
          ..write('groupId: $groupId, ')
          ..write('householdId: $householdId, ')
          ..write('queryFilter: $queryFilter, ')
          ..write('household: $household')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, slug, position, public,
      queryFilterString, groupId, householdId, queryFilter, household);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CookbookEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.slug == this.slug &&
          other.position == this.position &&
          other.public == this.public &&
          other.queryFilterString == this.queryFilterString &&
          other.groupId == this.groupId &&
          other.householdId == this.householdId &&
          other.queryFilter == this.queryFilter &&
          other.household == this.household);
}

class CookbooksCompanion extends UpdateCompanion<CookbookEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> slug;
  final Value<int> position;
  final Value<bool> public;
  final Value<String> queryFilterString;
  final Value<String> groupId;
  final Value<String> householdId;
  final Value<QueryFilter> queryFilter;
  final Value<Household> household;
  final Value<int> rowid;
  const CookbooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.slug = const Value.absent(),
    this.position = const Value.absent(),
    this.public = const Value.absent(),
    this.queryFilterString = const Value.absent(),
    this.groupId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.queryFilter = const Value.absent(),
    this.household = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CookbooksCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String slug,
    required int position,
    required bool public,
    required String queryFilterString,
    required String groupId,
    required String householdId,
    required QueryFilter queryFilter,
    required Household household,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        slug = Value(slug),
        position = Value(position),
        public = Value(public),
        queryFilterString = Value(queryFilterString),
        groupId = Value(groupId),
        householdId = Value(householdId),
        queryFilter = Value(queryFilter),
        household = Value(household);
  static Insertable<CookbookEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? slug,
    Expression<int>? position,
    Expression<bool>? public,
    Expression<String>? queryFilterString,
    Expression<String>? groupId,
    Expression<String>? householdId,
    Expression<String>? queryFilter,
    Expression<String>? household,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (slug != null) 'slug': slug,
      if (position != null) 'position': position,
      if (public != null) 'public': public,
      if (queryFilterString != null) 'query_filter_string': queryFilterString,
      if (groupId != null) 'group_id': groupId,
      if (householdId != null) 'household_id': householdId,
      if (queryFilter != null) 'query_filter': queryFilter,
      if (household != null) 'household': household,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CookbooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? slug,
      Value<int>? position,
      Value<bool>? public,
      Value<String>? queryFilterString,
      Value<String>? groupId,
      Value<String>? householdId,
      Value<QueryFilter>? queryFilter,
      Value<Household>? household,
      Value<int>? rowid}) {
    return CookbooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      position: position ?? this.position,
      public: public ?? this.public,
      queryFilterString: queryFilterString ?? this.queryFilterString,
      groupId: groupId ?? this.groupId,
      householdId: householdId ?? this.householdId,
      queryFilter: queryFilter ?? this.queryFilter,
      household: household ?? this.household,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (public.present) {
      map['public'] = Variable<bool>(public.value);
    }
    if (queryFilterString.present) {
      map['query_filter_string'] = Variable<String>(queryFilterString.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (queryFilter.present) {
      map['query_filter'] = Variable<String>(
          $CookbooksTable.$converterqueryFilter.toSql(queryFilter.value));
    }
    if (household.present) {
      map['household'] = Variable<String>(
          $CookbooksTable.$converterhousehold.toSql(household.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CookbooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('slug: $slug, ')
          ..write('position: $position, ')
          ..write('public: $public, ')
          ..write('queryFilterString: $queryFilterString, ')
          ..write('groupId: $groupId, ')
          ..write('householdId: $householdId, ')
          ..write('queryFilter: $queryFilter, ')
          ..write('household: $household, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListsTable extends ShoppingLists
    with TableInfo<$ShoppingListsTable, ShoppingListEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
      extras = GeneratedColumn<String>('extras', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Map<String, dynamic>>(
              $ShoppingListsTable.$converterextras);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<ShoppingListRecipeReference>,
      String> recipeReferences = GeneratedColumn<String>(
          'recipe_references', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<List<ShoppingListRecipeReference>>(
          $ShoppingListsTable.$converterrecipeReferences);
  @override
  late final GeneratedColumnWithTypeConverter<List<ShoppingListLabelSetting>,
      String> labelSettings = GeneratedColumn<String>(
          'label_settings', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<List<ShoppingListLabelSetting>>(
          $ShoppingListsTable.$converterlabelSettings);
  @override
  late final GeneratedColumnWithTypeConverter<List<ShoppingItem>, String>
      listItems = GeneratedColumn<String>('list_items', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<ShoppingItem>>(
              $ShoppingListsTable.$converterlistItems);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        extras,
        createdAt,
        updatedAt,
        groupId,
        userId,
        householdId,
        recipeReferences,
        labelSettings,
        listItems
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_lists';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingListEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingListEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      extras: $ShoppingListsTable.$converterextras.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extras'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id']),
      recipeReferences: $ShoppingListsTable.$converterrecipeReferences.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}recipe_references'])!),
      labelSettings: $ShoppingListsTable.$converterlabelSettings.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}label_settings'])!),
      listItems: $ShoppingListsTable.$converterlistItems.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}list_items'])!),
    );
  }

  @override
  $ShoppingListsTable createAlias(String alias) {
    return $ShoppingListsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterextras =
      const ExtrasMapConverter();
  static TypeConverter<List<ShoppingListRecipeReference>, String>
      $converterrecipeReferences = const RecipeReferencesConverter();
  static TypeConverter<List<ShoppingListLabelSetting>, String>
      $converterlabelSettings = const LabelSettingsConverter();
  static TypeConverter<List<ShoppingItem>, String> $converterlistItems =
      const ListItemsConverter();
}

class ShoppingListEntry extends DataClass
    implements Insertable<ShoppingListEntry> {
  final String id;
  final String name;
  final Map<String, dynamic> extras;
  final String createdAt;
  final String updatedAt;
  final String? groupId;
  final String? userId;
  final String? householdId;
  final List<ShoppingListRecipeReference> recipeReferences;
  final List<ShoppingListLabelSetting> labelSettings;
  final List<ShoppingItem> listItems;
  const ShoppingListEntry(
      {required this.id,
      required this.name,
      required this.extras,
      required this.createdAt,
      required this.updatedAt,
      this.groupId,
      this.userId,
      this.householdId,
      required this.recipeReferences,
      required this.labelSettings,
      required this.listItems});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['extras'] =
          Variable<String>($ShoppingListsTable.$converterextras.toSql(extras));
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || householdId != null) {
      map['household_id'] = Variable<String>(householdId);
    }
    {
      map['recipe_references'] = Variable<String>($ShoppingListsTable
          .$converterrecipeReferences
          .toSql(recipeReferences));
    }
    {
      map['label_settings'] = Variable<String>(
          $ShoppingListsTable.$converterlabelSettings.toSql(labelSettings));
    }
    {
      map['list_items'] = Variable<String>(
          $ShoppingListsTable.$converterlistItems.toSql(listItems));
    }
    return map;
  }

  ShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsCompanion(
      id: Value(id),
      name: Value(name),
      extras: Value(extras),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      householdId: householdId == null && nullToAbsent
          ? const Value.absent()
          : Value(householdId),
      recipeReferences: Value(recipeReferences),
      labelSettings: Value(labelSettings),
      listItems: Value(listItems),
    );
  }

  factory ShoppingListEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      extras: serializer.fromJson<Map<String, dynamic>>(json['extras']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      userId: serializer.fromJson<String?>(json['userId']),
      householdId: serializer.fromJson<String?>(json['householdId']),
      recipeReferences: serializer.fromJson<List<ShoppingListRecipeReference>>(
          json['recipeReferences']),
      labelSettings: serializer
          .fromJson<List<ShoppingListLabelSetting>>(json['labelSettings']),
      listItems: serializer.fromJson<List<ShoppingItem>>(json['listItems']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'extras': serializer.toJson<Map<String, dynamic>>(extras),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'groupId': serializer.toJson<String?>(groupId),
      'userId': serializer.toJson<String?>(userId),
      'householdId': serializer.toJson<String?>(householdId),
      'recipeReferences': serializer
          .toJson<List<ShoppingListRecipeReference>>(recipeReferences),
      'labelSettings':
          serializer.toJson<List<ShoppingListLabelSetting>>(labelSettings),
      'listItems': serializer.toJson<List<ShoppingItem>>(listItems),
    };
  }

  ShoppingListEntry copyWith(
          {String? id,
          String? name,
          Map<String, dynamic>? extras,
          String? createdAt,
          String? updatedAt,
          Value<String?> groupId = const Value.absent(),
          Value<String?> userId = const Value.absent(),
          Value<String?> householdId = const Value.absent(),
          List<ShoppingListRecipeReference>? recipeReferences,
          List<ShoppingListLabelSetting>? labelSettings,
          List<ShoppingItem>? listItems}) =>
      ShoppingListEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        extras: extras ?? this.extras,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        groupId: groupId.present ? groupId.value : this.groupId,
        userId: userId.present ? userId.value : this.userId,
        householdId: householdId.present ? householdId.value : this.householdId,
        recipeReferences: recipeReferences ?? this.recipeReferences,
        labelSettings: labelSettings ?? this.labelSettings,
        listItems: listItems ?? this.listItems,
      );
  ShoppingListEntry copyWithCompanion(ShoppingListsCompanion data) {
    return ShoppingListEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      extras: data.extras.present ? data.extras.value : this.extras,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      recipeReferences: data.recipeReferences.present
          ? data.recipeReferences.value
          : this.recipeReferences,
      labelSettings: data.labelSettings.present
          ? data.labelSettings.value
          : this.labelSettings,
      listItems: data.listItems.present ? data.listItems.value : this.listItems,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('extras: $extras, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('householdId: $householdId, ')
          ..write('recipeReferences: $recipeReferences, ')
          ..write('labelSettings: $labelSettings, ')
          ..write('listItems: $listItems')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, extras, createdAt, updatedAt,
      groupId, userId, householdId, recipeReferences, labelSettings, listItems);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.extras == this.extras &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.householdId == this.householdId &&
          other.recipeReferences == this.recipeReferences &&
          other.labelSettings == this.labelSettings &&
          other.listItems == this.listItems);
}

class ShoppingListsCompanion extends UpdateCompanion<ShoppingListEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<Map<String, dynamic>> extras;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> groupId;
  final Value<String?> userId;
  final Value<String?> householdId;
  final Value<List<ShoppingListRecipeReference>> recipeReferences;
  final Value<List<ShoppingListLabelSetting>> labelSettings;
  final Value<List<ShoppingItem>> listItems;
  final Value<int> rowid;
  const ShoppingListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.extras = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.recipeReferences = const Value.absent(),
    this.labelSettings = const Value.absent(),
    this.listItems = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListsCompanion.insert({
    required String id,
    required String name,
    required Map<String, dynamic> extras,
    required String createdAt,
    required String updatedAt,
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.householdId = const Value.absent(),
    required List<ShoppingListRecipeReference> recipeReferences,
    required List<ShoppingListLabelSetting> labelSettings,
    required List<ShoppingItem> listItems,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        extras = Value(extras),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        recipeReferences = Value(recipeReferences),
        labelSettings = Value(labelSettings),
        listItems = Value(listItems);
  static Insertable<ShoppingListEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? extras,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<String>? householdId,
    Expression<String>? recipeReferences,
    Expression<String>? labelSettings,
    Expression<String>? listItems,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (extras != null) 'extras': extras,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (householdId != null) 'household_id': householdId,
      if (recipeReferences != null) 'recipe_references': recipeReferences,
      if (labelSettings != null) 'label_settings': labelSettings,
      if (listItems != null) 'list_items': listItems,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<Map<String, dynamic>>? extras,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String?>? groupId,
      Value<String?>? userId,
      Value<String?>? householdId,
      Value<List<ShoppingListRecipeReference>>? recipeReferences,
      Value<List<ShoppingListLabelSetting>>? labelSettings,
      Value<List<ShoppingItem>>? listItems,
      Value<int>? rowid}) {
    return ShoppingListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      extras: extras ?? this.extras,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      recipeReferences: recipeReferences ?? this.recipeReferences,
      labelSettings: labelSettings ?? this.labelSettings,
      listItems: listItems ?? this.listItems,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (extras.present) {
      map['extras'] = Variable<String>(
          $ShoppingListsTable.$converterextras.toSql(extras.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (recipeReferences.present) {
      map['recipe_references'] = Variable<String>($ShoppingListsTable
          .$converterrecipeReferences
          .toSql(recipeReferences.value));
    }
    if (labelSettings.present) {
      map['label_settings'] = Variable<String>($ShoppingListsTable
          .$converterlabelSettings
          .toSql(labelSettings.value));
    }
    if (listItems.present) {
      map['list_items'] = Variable<String>(
          $ShoppingListsTable.$converterlistItems.toSql(listItems.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('extras: $extras, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('householdId: $householdId, ')
          ..write('recipeReferences: $recipeReferences, ')
          ..write('labelSettings: $labelSettings, ')
          ..write('listItems: $listItems, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealplanRulesTable extends MealplanRules
    with TableInfo<$MealplanRulesTable, MealplanRuleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealplanRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
      'day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queryFilterStringMeta =
      const VerificationMeta('queryFilterString');
  @override
  late final GeneratedColumn<String> queryFilterString =
      GeneratedColumn<String>('query_filter_string', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<MealplanRuleQueryFilter, String>
      queryFilter = GeneratedColumn<String>('query_filter', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<MealplanRuleQueryFilter>(
              $MealplanRulesTable.$converterqueryFilter);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        day,
        entryType,
        queryFilterString,
        groupId,
        householdId,
        queryFilter
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mealplan_rules';
  @override
  VerificationContext validateIntegrity(Insertable<MealplanRuleEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('query_filter_string')) {
      context.handle(
          _queryFilterStringMeta,
          queryFilterString.isAcceptableOrUnknown(
              data['query_filter_string']!, _queryFilterStringMeta));
    } else if (isInserting) {
      context.missing(_queryFilterStringMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealplanRuleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealplanRuleEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      queryFilterString: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}query_filter_string'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      queryFilter: $MealplanRulesTable.$converterqueryFilter.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}query_filter'])!),
    );
  }

  @override
  $MealplanRulesTable createAlias(String alias) {
    return $MealplanRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<MealplanRuleQueryFilter, String> $converterqueryFilter =
      const MealplanRuleQueryFilterConverter();
}

class MealplanRuleEntry extends DataClass
    implements Insertable<MealplanRuleEntry> {
  final String id;
  final String day;
  final String entryType;
  final String queryFilterString;
  final String groupId;
  final String householdId;
  final MealplanRuleQueryFilter queryFilter;
  const MealplanRuleEntry(
      {required this.id,
      required this.day,
      required this.entryType,
      required this.queryFilterString,
      required this.groupId,
      required this.householdId,
      required this.queryFilter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['entry_type'] = Variable<String>(entryType);
    map['query_filter_string'] = Variable<String>(queryFilterString);
    map['group_id'] = Variable<String>(groupId);
    map['household_id'] = Variable<String>(householdId);
    {
      map['query_filter'] = Variable<String>(
          $MealplanRulesTable.$converterqueryFilter.toSql(queryFilter));
    }
    return map;
  }

  MealplanRulesCompanion toCompanion(bool nullToAbsent) {
    return MealplanRulesCompanion(
      id: Value(id),
      day: Value(day),
      entryType: Value(entryType),
      queryFilterString: Value(queryFilterString),
      groupId: Value(groupId),
      householdId: Value(householdId),
      queryFilter: Value(queryFilter),
    );
  }

  factory MealplanRuleEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealplanRuleEntry(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      entryType: serializer.fromJson<String>(json['entryType']),
      queryFilterString: serializer.fromJson<String>(json['queryFilterString']),
      groupId: serializer.fromJson<String>(json['groupId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      queryFilter:
          serializer.fromJson<MealplanRuleQueryFilter>(json['queryFilter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'entryType': serializer.toJson<String>(entryType),
      'queryFilterString': serializer.toJson<String>(queryFilterString),
      'groupId': serializer.toJson<String>(groupId),
      'householdId': serializer.toJson<String>(householdId),
      'queryFilter': serializer.toJson<MealplanRuleQueryFilter>(queryFilter),
    };
  }

  MealplanRuleEntry copyWith(
          {String? id,
          String? day,
          String? entryType,
          String? queryFilterString,
          String? groupId,
          String? householdId,
          MealplanRuleQueryFilter? queryFilter}) =>
      MealplanRuleEntry(
        id: id ?? this.id,
        day: day ?? this.day,
        entryType: entryType ?? this.entryType,
        queryFilterString: queryFilterString ?? this.queryFilterString,
        groupId: groupId ?? this.groupId,
        householdId: householdId ?? this.householdId,
        queryFilter: queryFilter ?? this.queryFilter,
      );
  MealplanRuleEntry copyWithCompanion(MealplanRulesCompanion data) {
    return MealplanRuleEntry(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      queryFilterString: data.queryFilterString.present
          ? data.queryFilterString.value
          : this.queryFilterString,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      queryFilter:
          data.queryFilter.present ? data.queryFilter.value : this.queryFilter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealplanRuleEntry(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('entryType: $entryType, ')
          ..write('queryFilterString: $queryFilterString, ')
          ..write('groupId: $groupId, ')
          ..write('householdId: $householdId, ')
          ..write('queryFilter: $queryFilter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, day, entryType, queryFilterString, groupId, householdId, queryFilter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealplanRuleEntry &&
          other.id == this.id &&
          other.day == this.day &&
          other.entryType == this.entryType &&
          other.queryFilterString == this.queryFilterString &&
          other.groupId == this.groupId &&
          other.householdId == this.householdId &&
          other.queryFilter == this.queryFilter);
}

class MealplanRulesCompanion extends UpdateCompanion<MealplanRuleEntry> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> entryType;
  final Value<String> queryFilterString;
  final Value<String> groupId;
  final Value<String> householdId;
  final Value<MealplanRuleQueryFilter> queryFilter;
  final Value<int> rowid;
  const MealplanRulesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.entryType = const Value.absent(),
    this.queryFilterString = const Value.absent(),
    this.groupId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.queryFilter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealplanRulesCompanion.insert({
    required String id,
    required String day,
    required String entryType,
    required String queryFilterString,
    required String groupId,
    required String householdId,
    required MealplanRuleQueryFilter queryFilter,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        day = Value(day),
        entryType = Value(entryType),
        queryFilterString = Value(queryFilterString),
        groupId = Value(groupId),
        householdId = Value(householdId),
        queryFilter = Value(queryFilter);
  static Insertable<MealplanRuleEntry> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? entryType,
    Expression<String>? queryFilterString,
    Expression<String>? groupId,
    Expression<String>? householdId,
    Expression<String>? queryFilter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (entryType != null) 'entry_type': entryType,
      if (queryFilterString != null) 'query_filter_string': queryFilterString,
      if (groupId != null) 'group_id': groupId,
      if (householdId != null) 'household_id': householdId,
      if (queryFilter != null) 'query_filter': queryFilter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealplanRulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? day,
      Value<String>? entryType,
      Value<String>? queryFilterString,
      Value<String>? groupId,
      Value<String>? householdId,
      Value<MealplanRuleQueryFilter>? queryFilter,
      Value<int>? rowid}) {
    return MealplanRulesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      entryType: entryType ?? this.entryType,
      queryFilterString: queryFilterString ?? this.queryFilterString,
      groupId: groupId ?? this.groupId,
      householdId: householdId ?? this.householdId,
      queryFilter: queryFilter ?? this.queryFilter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (queryFilterString.present) {
      map['query_filter_string'] = Variable<String>(queryFilterString.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (queryFilter.present) {
      map['query_filter'] = Variable<String>(
          $MealplanRulesTable.$converterqueryFilter.toSql(queryFilter.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealplanRulesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('entryType: $entryType, ')
          ..write('queryFilterString: $queryFilterString, ')
          ..write('groupId: $groupId, ')
          ..write('householdId: $householdId, ')
          ..write('queryFilter: $queryFilter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealplansTable extends Mealplans
    with TableInfo<$MealplansTable, MealplanDbEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealplansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentTextMeta =
      const VerificationMeta('contentText');
  @override
  late final GeneratedColumn<String> contentText = GeneratedColumn<String>(
      'text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<MealplanRecipe?, String> recipe =
      GeneratedColumn<String>('recipe', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<MealplanRecipe?>($MealplansTable.$converterrecipe);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, entryType, title, contentText, recipeId, recipe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mealplans';
  @override
  VerificationContext validateIntegrity(Insertable<MealplanDbEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('text')) {
      context.handle(_contentTextMeta,
          contentText.isAcceptableOrUnknown(data['text']!, _contentTextMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealplanDbEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealplanDbEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      contentText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text']),
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id']),
      recipe: $MealplansTable.$converterrecipe.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe'])),
    );
  }

  @override
  $MealplansTable createAlias(String alias) {
    return $MealplansTable(attachedDatabase, alias);
  }

  static TypeConverter<MealplanRecipe?, String?> $converterrecipe =
      const MealplanRecipeConverter();
}

class MealplanDbEntry extends DataClass implements Insertable<MealplanDbEntry> {
  final int id;
  final String date;
  final String entryType;
  final String? title;
  final String? contentText;
  final String? recipeId;
  final MealplanRecipe? recipe;
  const MealplanDbEntry(
      {required this.id,
      required this.date,
      required this.entryType,
      this.title,
      this.contentText,
      this.recipeId,
      this.recipe});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['entry_type'] = Variable<String>(entryType);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || contentText != null) {
      map['text'] = Variable<String>(contentText);
    }
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    if (!nullToAbsent || recipe != null) {
      map['recipe'] =
          Variable<String>($MealplansTable.$converterrecipe.toSql(recipe));
    }
    return map;
  }

  MealplansCompanion toCompanion(bool nullToAbsent) {
    return MealplansCompanion(
      id: Value(id),
      date: Value(date),
      entryType: Value(entryType),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      contentText: contentText == null && nullToAbsent
          ? const Value.absent()
          : Value(contentText),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      recipe:
          recipe == null && nullToAbsent ? const Value.absent() : Value(recipe),
    );
  }

  factory MealplanDbEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealplanDbEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      entryType: serializer.fromJson<String>(json['entryType']),
      title: serializer.fromJson<String?>(json['title']),
      contentText: serializer.fromJson<String?>(json['contentText']),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
      recipe: serializer.fromJson<MealplanRecipe?>(json['recipe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'entryType': serializer.toJson<String>(entryType),
      'title': serializer.toJson<String?>(title),
      'contentText': serializer.toJson<String?>(contentText),
      'recipeId': serializer.toJson<String?>(recipeId),
      'recipe': serializer.toJson<MealplanRecipe?>(recipe),
    };
  }

  MealplanDbEntry copyWith(
          {int? id,
          String? date,
          String? entryType,
          Value<String?> title = const Value.absent(),
          Value<String?> contentText = const Value.absent(),
          Value<String?> recipeId = const Value.absent(),
          Value<MealplanRecipe?> recipe = const Value.absent()}) =>
      MealplanDbEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        entryType: entryType ?? this.entryType,
        title: title.present ? title.value : this.title,
        contentText: contentText.present ? contentText.value : this.contentText,
        recipeId: recipeId.present ? recipeId.value : this.recipeId,
        recipe: recipe.present ? recipe.value : this.recipe,
      );
  MealplanDbEntry copyWithCompanion(MealplansCompanion data) {
    return MealplanDbEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      title: data.title.present ? data.title.value : this.title,
      contentText:
          data.contentText.present ? data.contentText.value : this.contentText,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      recipe: data.recipe.present ? data.recipe.value : this.recipe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealplanDbEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('contentText: $contentText, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipe: $recipe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, entryType, title, contentText, recipeId, recipe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealplanDbEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.entryType == this.entryType &&
          other.title == this.title &&
          other.contentText == this.contentText &&
          other.recipeId == this.recipeId &&
          other.recipe == this.recipe);
}

class MealplansCompanion extends UpdateCompanion<MealplanDbEntry> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> entryType;
  final Value<String?> title;
  final Value<String?> contentText;
  final Value<String?> recipeId;
  final Value<MealplanRecipe?> recipe;
  const MealplansCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.entryType = const Value.absent(),
    this.title = const Value.absent(),
    this.contentText = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.recipe = const Value.absent(),
  });
  MealplansCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String entryType,
    this.title = const Value.absent(),
    this.contentText = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.recipe = const Value.absent(),
  })  : date = Value(date),
        entryType = Value(entryType);
  static Insertable<MealplanDbEntry> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? entryType,
    Expression<String>? title,
    Expression<String>? contentText,
    Expression<String>? recipeId,
    Expression<String>? recipe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (entryType != null) 'entry_type': entryType,
      if (title != null) 'title': title,
      if (contentText != null) 'text': contentText,
      if (recipeId != null) 'recipe_id': recipeId,
      if (recipe != null) 'recipe': recipe,
    });
  }

  MealplansCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? entryType,
      Value<String?>? title,
      Value<String?>? contentText,
      Value<String?>? recipeId,
      Value<MealplanRecipe?>? recipe}) {
    return MealplansCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      entryType: entryType ?? this.entryType,
      title: title ?? this.title,
      contentText: contentText ?? this.contentText,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe ?? this.recipe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contentText.present) {
      map['text'] = Variable<String>(contentText.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (recipe.present) {
      map['recipe'] = Variable<String>(
          $MealplansTable.$converterrecipe.toSql(recipe.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealplansCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('contentText: $contentText, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipe: $recipe')
          ..write(')'))
        .toString();
  }
}

abstract class _$HouseholdDatabase extends GeneratedDatabase {
  _$HouseholdDatabase(QueryExecutor e) : super(e);
  $HouseholdDatabaseManager get managers => $HouseholdDatabaseManager(this);
  late final $CookbooksTable cookbooks = $CookbooksTable(this);
  late final $ShoppingListsTable shoppingLists = $ShoppingListsTable(this);
  late final $MealplanRulesTable mealplanRules = $MealplanRulesTable(this);
  late final $MealplansTable mealplans = $MealplansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cookbooks, shoppingLists, mealplanRules, mealplans];
}

typedef $$CookbooksTableCreateCompanionBuilder = CookbooksCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String slug,
  required int position,
  required bool public,
  required String queryFilterString,
  required String groupId,
  required String householdId,
  required QueryFilter queryFilter,
  required Household household,
  Value<int> rowid,
});
typedef $$CookbooksTableUpdateCompanionBuilder = CookbooksCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> slug,
  Value<int> position,
  Value<bool> public,
  Value<String> queryFilterString,
  Value<String> groupId,
  Value<String> householdId,
  Value<QueryFilter> queryFilter,
  Value<Household> household,
  Value<int> rowid,
});

class $$CookbooksTableFilterComposer
    extends Composer<_$HouseholdDatabase, $CookbooksTable> {
  $$CookbooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get public => $composableBuilder(
      column: $table.public, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryFilterString => $composableBuilder(
      column: $table.queryFilterString,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<QueryFilter, QueryFilter, String>
      get queryFilter => $composableBuilder(
          column: $table.queryFilter,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Household, Household, String> get household =>
      $composableBuilder(
          column: $table.household,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$CookbooksTableOrderingComposer
    extends Composer<_$HouseholdDatabase, $CookbooksTable> {
  $$CookbooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get public => $composableBuilder(
      column: $table.public, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryFilterString => $composableBuilder(
      column: $table.queryFilterString,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryFilter => $composableBuilder(
      column: $table.queryFilter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get household => $composableBuilder(
      column: $table.household, builder: (column) => ColumnOrderings(column));
}

class $$CookbooksTableAnnotationComposer
    extends Composer<_$HouseholdDatabase, $CookbooksTable> {
  $$CookbooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get public =>
      $composableBuilder(column: $table.public, builder: (column) => column);

  GeneratedColumn<String> get queryFilterString => $composableBuilder(
      column: $table.queryFilterString, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QueryFilter, String> get queryFilter =>
      $composableBuilder(
          column: $table.queryFilter, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Household, String> get household =>
      $composableBuilder(column: $table.household, builder: (column) => column);
}

class $$CookbooksTableTableManager extends RootTableManager<
    _$HouseholdDatabase,
    $CookbooksTable,
    CookbookEntry,
    $$CookbooksTableFilterComposer,
    $$CookbooksTableOrderingComposer,
    $$CookbooksTableAnnotationComposer,
    $$CookbooksTableCreateCompanionBuilder,
    $$CookbooksTableUpdateCompanionBuilder,
    (
      CookbookEntry,
      BaseReferences<_$HouseholdDatabase, $CookbooksTable, CookbookEntry>
    ),
    CookbookEntry,
    PrefetchHooks Function()> {
  $$CookbooksTableTableManager(_$HouseholdDatabase db, $CookbooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CookbooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CookbooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CookbooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> slug = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<bool> public = const Value.absent(),
            Value<String> queryFilterString = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<QueryFilter> queryFilter = const Value.absent(),
            Value<Household> household = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CookbooksCompanion(
            id: id,
            name: name,
            description: description,
            slug: slug,
            position: position,
            public: public,
            queryFilterString: queryFilterString,
            groupId: groupId,
            householdId: householdId,
            queryFilter: queryFilter,
            household: household,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String slug,
            required int position,
            required bool public,
            required String queryFilterString,
            required String groupId,
            required String householdId,
            required QueryFilter queryFilter,
            required Household household,
            Value<int> rowid = const Value.absent(),
          }) =>
              CookbooksCompanion.insert(
            id: id,
            name: name,
            description: description,
            slug: slug,
            position: position,
            public: public,
            queryFilterString: queryFilterString,
            groupId: groupId,
            householdId: householdId,
            queryFilter: queryFilter,
            household: household,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CookbooksTableProcessedTableManager = ProcessedTableManager<
    _$HouseholdDatabase,
    $CookbooksTable,
    CookbookEntry,
    $$CookbooksTableFilterComposer,
    $$CookbooksTableOrderingComposer,
    $$CookbooksTableAnnotationComposer,
    $$CookbooksTableCreateCompanionBuilder,
    $$CookbooksTableUpdateCompanionBuilder,
    (
      CookbookEntry,
      BaseReferences<_$HouseholdDatabase, $CookbooksTable, CookbookEntry>
    ),
    CookbookEntry,
    PrefetchHooks Function()>;
typedef $$ShoppingListsTableCreateCompanionBuilder = ShoppingListsCompanion
    Function({
  required String id,
  required String name,
  required Map<String, dynamic> extras,
  required String createdAt,
  required String updatedAt,
  Value<String?> groupId,
  Value<String?> userId,
  Value<String?> householdId,
  required List<ShoppingListRecipeReference> recipeReferences,
  required List<ShoppingListLabelSetting> labelSettings,
  required List<ShoppingItem> listItems,
  Value<int> rowid,
});
typedef $$ShoppingListsTableUpdateCompanionBuilder = ShoppingListsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<Map<String, dynamic>> extras,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> groupId,
  Value<String?> userId,
  Value<String?> householdId,
  Value<List<ShoppingListRecipeReference>> recipeReferences,
  Value<List<ShoppingListLabelSetting>> labelSettings,
  Value<List<ShoppingItem>> listItems,
  Value<int> rowid,
});

class $$ShoppingListsTableFilterComposer
    extends Composer<_$HouseholdDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, dynamic>, Map<String, dynamic>,
          String>
      get extras => $composableBuilder(
          column: $table.extras,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<ShoppingListRecipeReference>,
          List<ShoppingListRecipeReference>, String>
      get recipeReferences => $composableBuilder(
          column: $table.recipeReferences,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<ShoppingListLabelSetting>,
          List<ShoppingListLabelSetting>, String>
      get labelSettings => $composableBuilder(
          column: $table.labelSettings,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<ShoppingItem>, List<ShoppingItem>, String>
      get listItems => $composableBuilder(
          column: $table.listItems,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$ShoppingListsTableOrderingComposer
    extends Composer<_$HouseholdDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extras => $composableBuilder(
      column: $table.extras, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeReferences => $composableBuilder(
      column: $table.recipeReferences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labelSettings => $composableBuilder(
      column: $table.labelSettings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get listItems => $composableBuilder(
      column: $table.listItems, builder: (column) => ColumnOrderings(column));
}

class $$ShoppingListsTableAnnotationComposer
    extends Composer<_$HouseholdDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get extras =>
      $composableBuilder(column: $table.extras, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ShoppingListRecipeReference>, String>
      get recipeReferences => $composableBuilder(
          column: $table.recipeReferences, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ShoppingListLabelSetting>, String>
      get labelSettings => $composableBuilder(
          column: $table.labelSettings, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ShoppingItem>, String> get listItems =>
      $composableBuilder(column: $table.listItems, builder: (column) => column);
}

class $$ShoppingListsTableTableManager extends RootTableManager<
    _$HouseholdDatabase,
    $ShoppingListsTable,
    ShoppingListEntry,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableAnnotationComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder,
    (
      ShoppingListEntry,
      BaseReferences<_$HouseholdDatabase, $ShoppingListsTable,
          ShoppingListEntry>
    ),
    ShoppingListEntry,
    PrefetchHooks Function()> {
  $$ShoppingListsTableTableManager(
      _$HouseholdDatabase db, $ShoppingListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<Map<String, dynamic>> extras = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> householdId = const Value.absent(),
            Value<List<ShoppingListRecipeReference>> recipeReferences =
                const Value.absent(),
            Value<List<ShoppingListLabelSetting>> labelSettings =
                const Value.absent(),
            Value<List<ShoppingItem>> listItems = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListsCompanion(
            id: id,
            name: name,
            extras: extras,
            createdAt: createdAt,
            updatedAt: updatedAt,
            groupId: groupId,
            userId: userId,
            householdId: householdId,
            recipeReferences: recipeReferences,
            labelSettings: labelSettings,
            listItems: listItems,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required Map<String, dynamic> extras,
            required String createdAt,
            required String updatedAt,
            Value<String?> groupId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String?> householdId = const Value.absent(),
            required List<ShoppingListRecipeReference> recipeReferences,
            required List<ShoppingListLabelSetting> labelSettings,
            required List<ShoppingItem> listItems,
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListsCompanion.insert(
            id: id,
            name: name,
            extras: extras,
            createdAt: createdAt,
            updatedAt: updatedAt,
            groupId: groupId,
            userId: userId,
            householdId: householdId,
            recipeReferences: recipeReferences,
            labelSettings: labelSettings,
            listItems: listItems,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShoppingListsTableProcessedTableManager = ProcessedTableManager<
    _$HouseholdDatabase,
    $ShoppingListsTable,
    ShoppingListEntry,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableAnnotationComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder,
    (
      ShoppingListEntry,
      BaseReferences<_$HouseholdDatabase, $ShoppingListsTable,
          ShoppingListEntry>
    ),
    ShoppingListEntry,
    PrefetchHooks Function()>;
typedef $$MealplanRulesTableCreateCompanionBuilder = MealplanRulesCompanion
    Function({
  required String id,
  required String day,
  required String entryType,
  required String queryFilterString,
  required String groupId,
  required String householdId,
  required MealplanRuleQueryFilter queryFilter,
  Value<int> rowid,
});
typedef $$MealplanRulesTableUpdateCompanionBuilder = MealplanRulesCompanion
    Function({
  Value<String> id,
  Value<String> day,
  Value<String> entryType,
  Value<String> queryFilterString,
  Value<String> groupId,
  Value<String> householdId,
  Value<MealplanRuleQueryFilter> queryFilter,
  Value<int> rowid,
});

class $$MealplanRulesTableFilterComposer
    extends Composer<_$HouseholdDatabase, $MealplanRulesTable> {
  $$MealplanRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queryFilterString => $composableBuilder(
      column: $table.queryFilterString,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MealplanRuleQueryFilter,
          MealplanRuleQueryFilter, String>
      get queryFilter => $composableBuilder(
          column: $table.queryFilter,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$MealplanRulesTableOrderingComposer
    extends Composer<_$HouseholdDatabase, $MealplanRulesTable> {
  $$MealplanRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryFilterString => $composableBuilder(
      column: $table.queryFilterString,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queryFilter => $composableBuilder(
      column: $table.queryFilter, builder: (column) => ColumnOrderings(column));
}

class $$MealplanRulesTableAnnotationComposer
    extends Composer<_$HouseholdDatabase, $MealplanRulesTable> {
  $$MealplanRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get queryFilterString => $composableBuilder(
      column: $table.queryFilterString, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealplanRuleQueryFilter, String>
      get queryFilter => $composableBuilder(
          column: $table.queryFilter, builder: (column) => column);
}

class $$MealplanRulesTableTableManager extends RootTableManager<
    _$HouseholdDatabase,
    $MealplanRulesTable,
    MealplanRuleEntry,
    $$MealplanRulesTableFilterComposer,
    $$MealplanRulesTableOrderingComposer,
    $$MealplanRulesTableAnnotationComposer,
    $$MealplanRulesTableCreateCompanionBuilder,
    $$MealplanRulesTableUpdateCompanionBuilder,
    (
      MealplanRuleEntry,
      BaseReferences<_$HouseholdDatabase, $MealplanRulesTable,
          MealplanRuleEntry>
    ),
    MealplanRuleEntry,
    PrefetchHooks Function()> {
  $$MealplanRulesTableTableManager(
      _$HouseholdDatabase db, $MealplanRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealplanRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealplanRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealplanRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<String> queryFilterString = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<MealplanRuleQueryFilter> queryFilter = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MealplanRulesCompanion(
            id: id,
            day: day,
            entryType: entryType,
            queryFilterString: queryFilterString,
            groupId: groupId,
            householdId: householdId,
            queryFilter: queryFilter,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String day,
            required String entryType,
            required String queryFilterString,
            required String groupId,
            required String householdId,
            required MealplanRuleQueryFilter queryFilter,
            Value<int> rowid = const Value.absent(),
          }) =>
              MealplanRulesCompanion.insert(
            id: id,
            day: day,
            entryType: entryType,
            queryFilterString: queryFilterString,
            groupId: groupId,
            householdId: householdId,
            queryFilter: queryFilter,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealplanRulesTableProcessedTableManager = ProcessedTableManager<
    _$HouseholdDatabase,
    $MealplanRulesTable,
    MealplanRuleEntry,
    $$MealplanRulesTableFilterComposer,
    $$MealplanRulesTableOrderingComposer,
    $$MealplanRulesTableAnnotationComposer,
    $$MealplanRulesTableCreateCompanionBuilder,
    $$MealplanRulesTableUpdateCompanionBuilder,
    (
      MealplanRuleEntry,
      BaseReferences<_$HouseholdDatabase, $MealplanRulesTable,
          MealplanRuleEntry>
    ),
    MealplanRuleEntry,
    PrefetchHooks Function()>;
typedef $$MealplansTableCreateCompanionBuilder = MealplansCompanion Function({
  Value<int> id,
  required String date,
  required String entryType,
  Value<String?> title,
  Value<String?> contentText,
  Value<String?> recipeId,
  Value<MealplanRecipe?> recipe,
});
typedef $$MealplansTableUpdateCompanionBuilder = MealplansCompanion Function({
  Value<int> id,
  Value<String> date,
  Value<String> entryType,
  Value<String?> title,
  Value<String?> contentText,
  Value<String?> recipeId,
  Value<MealplanRecipe?> recipe,
});

class $$MealplansTableFilterComposer
    extends Composer<_$HouseholdDatabase, $MealplansTable> {
  $$MealplansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentText => $composableBuilder(
      column: $table.contentText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MealplanRecipe?, MealplanRecipe, String>
      get recipe => $composableBuilder(
          column: $table.recipe,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$MealplansTableOrderingComposer
    extends Composer<_$HouseholdDatabase, $MealplansTable> {
  $$MealplansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentText => $composableBuilder(
      column: $table.contentText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipe => $composableBuilder(
      column: $table.recipe, builder: (column) => ColumnOrderings(column));
}

class $$MealplansTableAnnotationComposer
    extends Composer<_$HouseholdDatabase, $MealplansTable> {
  $$MealplansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contentText => $composableBuilder(
      column: $table.contentText, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealplanRecipe?, String> get recipe =>
      $composableBuilder(column: $table.recipe, builder: (column) => column);
}

class $$MealplansTableTableManager extends RootTableManager<
    _$HouseholdDatabase,
    $MealplansTable,
    MealplanDbEntry,
    $$MealplansTableFilterComposer,
    $$MealplansTableOrderingComposer,
    $$MealplansTableAnnotationComposer,
    $$MealplansTableCreateCompanionBuilder,
    $$MealplansTableUpdateCompanionBuilder,
    (
      MealplanDbEntry,
      BaseReferences<_$HouseholdDatabase, $MealplansTable, MealplanDbEntry>
    ),
    MealplanDbEntry,
    PrefetchHooks Function()> {
  $$MealplansTableTableManager(_$HouseholdDatabase db, $MealplansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealplansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealplansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealplansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> contentText = const Value.absent(),
            Value<String?> recipeId = const Value.absent(),
            Value<MealplanRecipe?> recipe = const Value.absent(),
          }) =>
              MealplansCompanion(
            id: id,
            date: date,
            entryType: entryType,
            title: title,
            contentText: contentText,
            recipeId: recipeId,
            recipe: recipe,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required String entryType,
            Value<String?> title = const Value.absent(),
            Value<String?> contentText = const Value.absent(),
            Value<String?> recipeId = const Value.absent(),
            Value<MealplanRecipe?> recipe = const Value.absent(),
          }) =>
              MealplansCompanion.insert(
            id: id,
            date: date,
            entryType: entryType,
            title: title,
            contentText: contentText,
            recipeId: recipeId,
            recipe: recipe,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MealplansTableProcessedTableManager = ProcessedTableManager<
    _$HouseholdDatabase,
    $MealplansTable,
    MealplanDbEntry,
    $$MealplansTableFilterComposer,
    $$MealplansTableOrderingComposer,
    $$MealplansTableAnnotationComposer,
    $$MealplansTableCreateCompanionBuilder,
    $$MealplansTableUpdateCompanionBuilder,
    (
      MealplanDbEntry,
      BaseReferences<_$HouseholdDatabase, $MealplansTable, MealplanDbEntry>
    ),
    MealplanDbEntry,
    PrefetchHooks Function()>;

class $HouseholdDatabaseManager {
  final _$HouseholdDatabase _db;
  $HouseholdDatabaseManager(this._db);
  $$CookbooksTableTableManager get cookbooks =>
      $$CookbooksTableTableManager(_db, _db.cookbooks);
  $$ShoppingListsTableTableManager get shoppingLists =>
      $$ShoppingListsTableTableManager(_db, _db.shoppingLists);
  $$MealplanRulesTableTableManager get mealplanRules =>
      $$MealplanRulesTableTableManager(_db, _db.mealplanRules);
  $$MealplansTableTableManager get mealplans =>
      $$MealplansTableTableManager(_db, _db.mealplans);
}
