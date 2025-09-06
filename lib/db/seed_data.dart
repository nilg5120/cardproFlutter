part of 'database.dart';

extension SeedData on AppDatabase {
  Future<void> ensureInitialCardsAndDeckExist() async {
    try {
      debugPrint('Seeding initial data...');

      // Ensure card effects exist first
      await ensureDefaultCardEffectsExist();
      debugPrint('Card effects ensured.');

      // Create initial 10 cards if none exist
      final existingCards = await select(mtgCards).get();
      debugPrint('Existing cards: ${existingCards.length}');

      if (existingCards.isEmpty) {
        debugPrint('Creating initial cards (10 types)...');

        final effects = await select(cardEffects).get();
        if (effects.isEmpty) {
          throw Exception('No card effects found');
        }
        final effect = effects.first;
        debugPrint('Using effect: ${effect.name} (ID: ${effect.id})');

        final insertedCards = <MtgCard>[];

        Future<MtgCard> addCard(String name, String rarity, int number) async {
          final card = await into(mtgCards).insertReturning(
            MtgCardsCompanion.insert(
              name: name,
              rarity: Value(rarity),
              setName: const Value('Alpha'),
              cardnumber: Value(number),
              effectId: effect.id,
            ),
          );
          debugPrint('Created card: $name (ID: ${card.id})');
          return card;
        }

        insertedCards.add(await addCard('Lightning Bolt', 'C', 116));
        insertedCards.add(await addCard('Counterspell', 'U', 69));
        insertedCards.add(await addCard('Llanowar Elves', 'C', 213));
        insertedCards.add(await addCard('Serra Angel', 'U', 34));
        insertedCards.add(await addCard('Giant Growth', 'C', 188));
        insertedCards.add(await addCard('Dark Ritual', 'C', 104));
        insertedCards.add(await addCard('Shivan Dragon', 'R', 163));
        insertedCards.add(await addCard('Swords to Plowshares', 'U', 33));
        insertedCards.add(await addCard('Ancestral Recall', 'R', 17));
        insertedCards.add(await addCard('Black Lotus', 'R', 233));

        final now = DateTime.now();
        await batch((b) {
          b.insertAll(
            cardInstances,
            insertedCards
                .map(
                  (c) => CardInstancesCompanion.insert(
                    cardId: c.id,
                    description: const Value('Initial card'),
                    updatedAt: Value(now),
                  ),
                )
                .toList(),
          );
        });
        debugPrint('Created initial card instances (10).');
      }

      // Ensure at least one instance exists for existing cards
      final instancesCount = await cardInstances.count().getSingle();
      debugPrint('Existing instances: $instancesCount');
      if (instancesCount == 0) {
        debugPrint('Creating instances for existing cards...');
        final cards = await (select(mtgCards)..limit(10)).get();
        final now = DateTime.now();
        if (cards.isNotEmpty) {
          await batch((b) {
            b.insertAll(
              cardInstances,
              cards
                  .map(
                    (c) => CardInstancesCompanion.insert(
                      cardId: c.id,
                      description: const Value('Initial card'),
                      updatedAt: Value(now),
                    ),
                  )
                  .toList(),
            );
          });
          debugPrint('Created instances for existing cards.');
        }
      }

      // Create 2 default decks if none exist and assign cards
      final decks = await (select(containers)
            ..where((t) => t.containerType.equals('deck')))
          .get();
      debugPrint('Existing decks: ${decks.length}');

      if (decks.isEmpty) {
        debugPrint('Creating default decks (2)...');

        final deckA = await into(containers).insertReturning(
          ContainersCompanion.insert(
            name: const Value('Default Deck A'),
            description: const Value('Auto-created deck A'),
            containerType: 'deck',
          ),
        );
        final deckB = await into(containers).insertReturning(
          ContainersCompanion.insert(
            name: const Value('Default Deck B'),
            description: const Value('Auto-created deck B'),
            containerType: 'deck',
          ),
        );
        debugPrint('Created decks A(ID: ${deckA.id}) and B(ID: ${deckB.id})');

        final instances = await select(cardInstances).get();
        final firstHalf = instances.take(5).toList();
        final secondHalf = instances.skip(5).take(5).toList();
        debugPrint('Assigning ${firstHalf.length} to Deck A, ${secondHalf.length} to Deck B');

        await batch((b) {
          if (firstHalf.isNotEmpty) {
            b.insertAll(
              containerCardLocations,
              firstHalf
                  .map((ci) => ContainerCardLocationsCompanion.insert(
                        containerId: deckA.id,
                        cardInstanceId: ci.id,
                        location: 'main',
                      ))
                  .toList(),
            );
          }
          if (secondHalf.isNotEmpty) {
            b.insertAll(
              containerCardLocations,
              secondHalf
                  .map((ci) => ContainerCardLocationsCompanion.insert(
                        containerId: deckB.id,
                        cardInstanceId: ci.id,
                        location: 'main',
                      ))
                  .toList(),
            );
          }
        });
        debugPrint('Added cards to both decks.');
      }

      debugPrint('Seeding complete.');
    } catch (e, stackTrace) {
      debugPrint('Seeding error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> ensureDefaultCardEffectsExist() async {
    final effectsCount = await cardEffects.count().getSingle();
    if (effectsCount == 0) {
      await batch((batch) {
        batch.insertAll(cardEffects, [
          CardEffectsCompanion.insert(
            name: 'Basic',
            description: 'No special effect',
          ),
          CardEffectsCompanion.insert(
            name: 'Energy Boost',
            description: 'Gain additional energy',
          ),
          CardEffectsCompanion.insert(
            name: 'Damage Up',
            description: 'Increase dealt damage',
          ),
        ]);
      });
    }
  }
}

