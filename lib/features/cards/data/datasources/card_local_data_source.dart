import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:drift/drift.dart';

abstract class CardLocalDataSource {
  Future<List<CardWithInstanceModel>> getCards();
  Future<CardWithInstanceModel> addCard({
    required String name,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required int effectId,
    required String? description,
  });
  Future<void> deleteCard(CardInstanceModel instance);
  Future<void> editCard(CardInstanceModel instance, String description);
}

class CardLocalDataSourceImpl implements CardLocalDataSource {
  final AppDatabase database;

  CardLocalDataSourceImpl({required this.database});

  @override
  Future<List<CardWithInstanceModel>> getCards() async {
    final results = await database.getCardWithMaster();
    return results
        .map((tuple) => CardWithInstanceModel.fromDrift(tuple.$1, tuple.$2))
        .toList();
  }

  @override
  Future<CardWithInstanceModel> addCard({
    required String name,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required int effectId,
    required String? description,
  }) async {
    // Check if card already exists
    final existingCard = await (database.select(database.pokemonCards)
          ..where((tbl) =>
              tbl.name.equals(name) &
              tbl.setName.equals(setName ?? '') &
              tbl.cardnumber.equals(cardNumber ?? 0)))
        .getSingleOrNull();

    // Insert or get existing card
    final cardId = existingCard?.id ??
        (await database.into(database.pokemonCards).insertReturning(
              PokemonCardsCompanion.insert(
                name: name,
                rarity: Value(rarity),
                setName: Value(setName),
                cardnumber: Value(cardNumber),
                effectId: effectId,
              ),
            ))
            .id;

    // Insert card instance
    final instanceId = await database.into(database.cardInstances).insertReturning(
          CardInstancesCompanion.insert(
            cardId: cardId,
            description: Value(description),
            updatedAt: Value(DateTime.now()),
          ),
        );

    // Get the inserted card and instance
    final card = await (database.select(database.pokemonCards)
          ..where((tbl) => tbl.id.equals(cardId)))
        .getSingle();
    
    return CardWithInstanceModel.fromDrift(card, instanceId);
  }

  @override
  Future<void> deleteCard(CardInstanceModel instance) async {
    await (database.delete(database.cardInstances)
          ..where((tbl) => tbl.id.equals(instance.id)))
        .go();
  }

  @override
  Future<void> editCard(CardInstanceModel instance, String description) async {
    await (database.update(database.cardInstances)
          ..where((tbl) => tbl.id.equals(instance.id)))
        .write(
      CardInstancesCompanion(
        description: Value(description),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
