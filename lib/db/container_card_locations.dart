import 'package:drift/drift.dart';

class DeckCardLocations extends Table {
  IntColumn get containerId => integer()();          // Containers.id
  TextColumn get cardInstanceId => text()();   // CardInstances.id
  TextColumn get location => text()();         // 'main', 'side' など

  @override
  Set<Column> get primaryKey => {containerId, cardInstanceId, location};
}
