import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'connection/connection.dart';

part 'sync_queue_storage.g.dart';

/// Represents a pending offline operation that needs to be synced to the server.
@DataClassName('PendingOperationEntry')
class PendingOperations extends Table {
  /// Auto-increment primary key – also determines FIFO order.
  IntColumn get id => integer().autoIncrement()();

  /// The type of write operation: 'create', 'update', 'delete'.
  TextColumn get actionType => text()();

  /// The entity being modified: 'shopping_list', 'shopping_item', 'mealplan'.
  TextColumn get entityType => text()();

  /// The server-side or local ID of the entity (nullable for creates).
  TextColumn get entityId => text().nullable()();

  /// JSON-encoded payload with all data needed to replay the operation.
  TextColumn get payload => text()();

  /// Timestamp when the operation was enqueued (for debugging / ordering).
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [PendingOperations])
class SyncQueueDatabase extends _$SyncQueueDatabase {
  SyncQueueDatabase._() : super(openConnection(name: 'sync_queue'));

  static final SyncQueueDatabase _instance = SyncQueueDatabase._();
  factory SyncQueueDatabase() => _instance;

  @override
  int get schemaVersion => 1;
}

/// High-level helper to read / write the pending-operations queue.
class SyncQueueStorage {
  final SyncQueueDatabase _db = SyncQueueDatabase();

  /// Enqueue a new pending operation.
  Future<void> enqueue({
    required String actionType,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> payload,
  }) async {
    await _db.into(_db.pendingOperations).insert(
      PendingOperationsCompanion.insert(
        actionType: actionType,
        entityType: entityType,
        entityId: Value(entityId),
        payload: json.encode(payload),
      ),
    );
    debugPrint('SyncQueue: enqueued $actionType $entityType ${entityId ?? "(new)"}');
  }

  /// Get all pending operations sorted by creation time (FIFO).
  Future<List<PendingOperationEntry>> getAll() async {
    return (_db.select(_db.pendingOperations)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Remove a single operation after it has been successfully synced.
  Future<void> remove(int id) async {
    await (_db.delete(_db.pendingOperations)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Number of pending operations.
  Future<int> count() async {
    final rows = await getAll();
    return rows.length;
  }

  /// Remove all pending operations (e.g. on logout).
  Future<void> clearAll() async {
    await _db.delete(_db.pendingOperations).go();
  }
}

