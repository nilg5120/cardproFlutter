import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/decks/data/models/container_model.dart';
import 'package:drift/drift.dart';

abstract class DeckLocalDataSource {
  Future<List<ContainerModel>> getDecks();
  Future<ContainerModel> addDeck({
    required String name,
    required String? description,
  });
  Future<void> deleteDeck({
    required int id,
  });
  Future<ContainerModel> editDeck({
    required int id,
    required String name,
    required String? description,
  });
  Future<void> setActiveDeck({
    required int id,
  });
}

class DeckLocalDataSourceImpl implements DeckLocalDataSource {
  final AppDatabase database;

  DeckLocalDataSourceImpl({required this.database});

  @override
  Future<List<ContainerModel>> getDecks() async {
    final decks = await (database.select(database.containers)
          ..where((tbl) => tbl.containerType.equals('deck')))
        .get();
    return decks.map((deck) => ContainerModel.fromDrift(deck)).toList();
  }

  @override
  Future<ContainerModel> addDeck({
    required String name,
    required String? description,
  }) async {
    final deck = await database.into(database.containers).insertReturning(
          ContainersCompanion.insert(
            name: Value(name),
            description: Value(description),
            containerType: 'deck',
          ),
        );
    return ContainerModel.fromDrift(deck);
  }

  @override
  Future<void> deleteDeck({required int id}) async {
    await (database.delete(database.containers)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<ContainerModel> editDeck({
    required int id,
    required String name,
    required String? description,
  }) async {
    await (database.update(database.containers)..where((tbl) => tbl.id.equals(id))).write(
      ContainersCompanion(
        name: Value(name),
        description: Value(description),
      ),
    );
    
    final updatedDeck = await (database.select(database.containers)..where((tbl) => tbl.id.equals(id))).getSingle();
    return ContainerModel.fromDrift(updatedDeck);
  }

  @override
  Future<void> setActiveDeck({required int id}) async {
    await database.setActiveDeck(id);
  }
}
