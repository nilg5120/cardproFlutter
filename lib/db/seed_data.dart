part of 'database.dart';

extension SeedData on AppDatabase {
  Future<void> ensureInitialCardsAndDeckExist() async {
    try {
      debugPrint('Seeding initial data...');

      // Ensure effects exist first
      await ensureDefaultCardEffectsExist();
      debugPrint('Card effects ensured.');

      // Seed cards if none exist
      final existingCards = await select(mtgCards).get();
      debugPrint('Existing cards: ${existingCards.length}');

      if (existingCards.isEmpty) {
        debugPrint('Creating initial cards...');

        final effects = await select(cardEffects).get();
        if (effects.isEmpty) {
          throw Exception('No card effects found');
        }
        final effect = effects.first;
        debugPrint('Using effect: ${effect.name} (ID: ${effect.id})');

        final bolt = await into(mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Lightning Bolt',
            rarity: const Value('C'),
            setName: const Value('Alpha'),
            cardnumber: const Value(116),
            effectId: effect.id,
          ),
        );
        debugPrint('Created card: Lightning Bolt (ID: ${bolt.id})');

        final counterspell = await into(mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Counterspell',
            rarity: const Value('U'),
            setName: const Value('Alpha'),
            cardnumber: const Value(69),
            effectId: effect.id,
          ),
        );
        debugPrint('Created card: Counterspell (ID: ${counterspell.id})');

        final llanowar = await into(mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Llanowar Elves',
            rarity: const Value('C'),
            setName: const Value('Alpha'),
            cardnumber: const Value(213),
            effectId: effect.id,
          ),
        );
        debugPrint('Created card: Llanowar Elves (ID: ${llanowar.id})');

        // Create instances for the created cards
        final now = DateTime.now();
        await batch((b) {
          b.insertAll(cardInstances, [
            CardInstancesCompanion.insert(
              cardId: bolt.id,
              description: const Value('Initial card'),
              updatedAt: Value(now),
            ),
            CardInstancesCompanion.insert(
              cardId: counterspell.id,
              description: const Value('Initial card'),
              updatedAt: Value(now),
            ),
            CardInstancesCompanion.insert(
              cardId: llanowar.id,
              description: const Value('Initial card'),
              updatedAt: Value(now),
            ),
          ]);
        });
        debugPrint('Created initial card instances.');
      }

      // Ensure at least some instances exist even if cards already existed
      final instancesCount = await cardInstances.count().getSingle();
      debugPrint('Existing instances: $instancesCount');
      if (instancesCount == 0) {
        debugPrint('Creating instances for existing cards...');
        final cards = await (select(mtgCards)..limit(3)).get();
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

      // Seed a default deck if none exist
      final decks = await (select(containers)
            ..where((t) => t.containerType.equals('deck')))
          .get();
      debugPrint('Existing decks: ${decks.length}');

      if (decks.isEmpty) {
        debugPrint('Creating default deck...');

        final deck = await into(containers).insertReturning(
          ContainersCompanion.insert(
            name: const Value('Default Deck'),
            description: const Value('Auto-created deck'),
            containerType: 'deck',
          ),
        );
        debugPrint('Created deck (ID: ${deck.id})');

        final instances = await select(cardInstances).get();
        final selected = instances.take(3).toList();
        debugPrint('Adding ${selected.length} cards to the deck...');

        if (selected.isNotEmpty) {
          await batch((b) {
            b.insertAll(
              containerCardLocations,
              selected
                  .map((ci) => ContainerCardLocationsCompanion.insert(
                        containerId: deck.id,
                        cardInstanceId: ci.id,
                        location: 'main',
                      ))
                  .toList(),
            );
          });
          debugPrint('Added cards to the deck.');
        }
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
