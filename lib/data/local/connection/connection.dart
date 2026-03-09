import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection({String name = 'mealique'}) {
  return driftDatabase(name: name);
}
