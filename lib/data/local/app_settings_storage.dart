import 'package:drift/drift.dart';

part 'app_settings_storage.g.dart';

// Definition der Tabelle
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// DAO for accessing the settings
@DriftAccessor(tables: [AppSettings])
// Ersetzen Sie 'GeneratedDatabase' unten durch Ihre konkrete Datenbankklasse (z.B. AppDatabase)
class AppSettingsDao extends DatabaseAccessor<GeneratedDatabase> with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  // Retrieve setting
  Future<String?> getSetting(String key) async {
    final query = select(appSettings)..where((tbl) => tbl.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  // Save settings and update existing ones
  Future<void> saveSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }

  // Delete settings
  Future<void> deleteSetting(String key) async {
    await (delete(appSettings)..where((tbl) => tbl.key.equals(key))).go();
  }
}