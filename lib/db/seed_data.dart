part of 'database.dart';

extension SeedData on AppDatabase {
  Future<void> ensureInitialCardsAndDeckExist() async {
    try {
      debugPrint('Seeding initial data...');

      await ensureDefaultCardEffectsExist();
      debugPrint('Card effects ensured.');

      final existingCards = await select(mtgCards).get();
      debugPrint('Existing cards: ${existingCards.length}');

      if (existingCards.isEmpty) {
        debugPrint('Creating initial cards (${_seedCards.length} types)...');

        final effects = await select(cardEffects).get();
        if (effects.isEmpty) {
          throw Exception('No card effects found');
        }
        final effect = effects.first;
        debugPrint('Using effect: ${effect.name} (ID: ${effect.id})');

        final insertedCards = <MtgCard>[];
        for (final seed in _seedCards) {
          final nameEn = seed.nameEn ?? seed.name;
          final oracleDisplay = seed.oracleId ?? 'n/a';
          final card = await into(mtgCards).insertReturning(
            MtgCardsCompanion.insert(
              name: seed.name,
              effectId: effect.id,
            ).copyWith(
              rarity: Value(seed.rarity),
              setName: Value(seed.setName),
              cardnumber: Value(seed.cardNumber),
              nameEn: Value(nameEn),
              nameJa: Value(seed.nameJa),
              oracleId: Value(seed.oracleId),
            ),
          );
          debugPrint(
            'Created card: ${seed.name} (ID: ${card.id}, oracleId: $oracleDisplay)',
          );
          insertedCards.add(card);
        }

        final now = DateTime.now();
        if (insertedCards.isNotEmpty) {
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
          debugPrint('Created initial card instances (${insertedCards.length}).');
        }
      }

      // Ensure there is at least one instance for existing cards
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

      // Create two default decks when missing and assign cards
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
        final deckAList = instances.take(8).toList();
        final remainingForB = instances.skip(8).take(2).toList();
        // Reuse three cards from deck A so deck B has some overlap
        final duplicatesFromA = deckAList.take(3).toList();
        final deckBList = [...remainingForB, ...duplicatesFromA];

        debugPrint('Assigning to Deck A: ${deckAList.length}');
        debugPrint(
          'Assigning to Deck B: ${deckBList.length} (includes ${duplicatesFromA.length} duplicates from A)',
        );

        await batch((b) {
          if (deckAList.isNotEmpty) {
            b.insertAll(
              containerCardLocations,
              deckAList
                  .map((ci) => ContainerCardLocationsCompanion.insert(
                        containerId: deckA.id,
                        cardInstanceId: ci.id,
                        location: 'main',
                      ))
                  .toList(),
            );
          }
          if (deckBList.isNotEmpty) {
            b.insertAll(
              containerCardLocations,
              deckBList
                  .map((ci) => ContainerCardLocationsCompanion.insert(
                        containerId: deckB.id,
                        cardInstanceId: ci.id,
                        location: 'main',
                      ))
                  .toList(),
            );
          }
        });
        debugPrint('Added cards to both decks with overlap.');
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

  /// Prepare a default non-deck container.
  /// - Idempotent: inserts only when no non-deck container exists.
  /// - Inserts a container named 'Hokan-ko' (drawer) for legacy data.
  Future<void> ensureInitialContainersExist() async {
    // Insert a drawer container only if no non-deck container exists.
    final nonDeckContainers = await (select(containers)
          ..where((t) => t.containerType.isNotValue('deck')))
        .get();
    if (nonDeckContainers.isEmpty) {
      await into(containers).insert(
        ContainersCompanion.insert(
          name: const Value('\u4fdd\u7ba1\u5eab'),
          description: const Value(null),
          containerType: 'drawer',
        ),
      );
      debugPrint('Created initial container: \u4fdd\u7ba1\u5eab (type: drawer)');
    }
  }
}

class _SeedCard {
  final String name;
  final String? nameEn;
  final String? nameJa;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final String? oracleId;

  const _SeedCard({
    required this.name,
    this.nameEn,
    this.nameJa,
    this.rarity,
    this.setName,
    this.cardNumber,
    this.oracleId,
  });
}

const List<_SeedCard> _seedCards = [
  _SeedCard(
    name: 'Lightning Bolt',
    nameEn: 'Lightning Bolt',
    nameJa: '\u7a32\u59bb',
    rarity: 'C',
    setName: 'Limited Edition Alpha',
    cardNumber: 161,
    oracleId: '4457ed35-7c10-48c8-9776-456485fdf070',
  ),
  _SeedCard(
    name: 'Counterspell',
    nameEn: 'Counterspell',
    nameJa: '\u5bfe\u6297\u546a\u6587',
    rarity: 'U',
    setName: 'Limited Edition Alpha',
    cardNumber: 54,
    oracleId: 'cc187110-1148-4090-bbb8-e205694a39f5',
  ),
  _SeedCard(
    name: 'Llanowar Elves',
    nameEn: 'Llanowar Elves',
    nameJa: '\u30e9\u30ce\u30ef\u30fc\u30eb\u306e\u30a8\u30eb\u30d5',
    rarity: 'C',
    setName: 'Limited Edition Alpha',
    cardNumber: 210,
    oracleId: '68954295-54e3-4303-a6bc-fc4547a4e3a3',
  ),
  _SeedCard(
    name: 'Serra Angel',
    nameEn: 'Serra Angel',
    nameJa: '\u30bb\u30e9\u306e\u5929\u4f7f',
    rarity: 'U',
    setName: 'Limited Edition Alpha',
    cardNumber: 39,
    oracleId: '4b7ac066-e5c7-43e6-9e7e-2739b24a905d',
  ),
  _SeedCard(
    name: 'Giant Growth',
    nameEn: 'Giant Growth',
    nameJa: '\u5de8\u5927\u5316',
    rarity: 'C',
    setName: 'Limited Edition Alpha',
    cardNumber: 197,
    oracleId: '5748ebf1-24e3-499d-ab7c-c2cebd462a24',
  ),
  _SeedCard(
    name: 'Dark Ritual',
    nameEn: 'Dark Ritual',
    nameJa: '\u95c7\u306e\u5100\u5f0f',
    rarity: 'C',
    setName: 'Limited Edition Alpha',
    cardNumber: 98,
    oracleId: '53f7c868-b03e-4fc2-8dcf-a75bbfa3272b',
  ),
  _SeedCard(
    name: 'Shivan Dragon',
    nameEn: 'Shivan Dragon',
    nameJa: '\u30b7\u30f4\u5c71\u306e\u30c9\u30e9\u30b4\u30f3',
    rarity: 'R',
    setName: 'Limited Edition Alpha',
    cardNumber: 174,
    oracleId: '711eea87-0fa3-46e0-a42b-fa5a86455f04',
  ),
  _SeedCard(
    name: 'Swords to Plowshares',
    nameEn: 'Swords to Plowshares',
    nameJa: '\u5263\u3092\u936c\u306b',
    rarity: 'U',
    setName: 'Limited Edition Alpha',
    cardNumber: 40,
    oracleId: 'b1544f21-7e98-461b-aed5-e748b0168c52',
  ),
  _SeedCard(
    name: 'Ancestral Recall',
    nameEn: 'Ancestral Recall',
    nameJa: '\u7956\u5148\u306e\u5e7b\u8996',
    rarity: 'R',
    setName: 'Limited Edition Alpha',
    cardNumber: 47,
    oracleId: '550c74d4-1fcb-406a-b02a-639a760a4380',
  ),
  _SeedCard(
    name: 'Black Lotus',
    nameEn: 'Black Lotus',
    nameJa: '\u30d6\u30e9\u30c3\u30af\u30fb\u30ed\u30fc\u30bf\u30b9',
    rarity: 'R',
    setName: 'Limited Edition Alpha',
    cardNumber: 232,
    oracleId: '5089ec1a-f881-4d55-af14-5d996171203b',
  ),
];
