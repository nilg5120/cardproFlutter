import 'package:drift/drift.dart';

class DeckCardLocations extends Table {
  TextColumn get deckId => text()();           // デッキID
  TextColumn get cardInstanceId => text()();   // CardInstances.id
  TextColumn get location => text()();         // 'main', 'side' など

  @override
  Set<Column> get primaryKey => {deckId, cardInstanceId, location};
}
