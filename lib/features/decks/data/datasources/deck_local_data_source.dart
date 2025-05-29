import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/decks/data/models/container_model.dart';
import 'package:drift/drift.dart';

abstract class DeckLocalDataSource {
  Future<List<ContainerModel>> getDecks();
  Future<ContainerModel> addDeck({
    required String name,
    required String? description,
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
}
