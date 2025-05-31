import 'package:drift/drift.dart';

class ContainerCardLocations extends Table {
  IntColumn get containerId => integer()();          // Containers.id
  IntColumn get cardInstanceId => integer()();   // CardInstances.id
  TextColumn get location => text()();         // 'main', 'side' など

  @override
  Set<Column> get primaryKey => {containerId, cardInstanceId, location};
}
