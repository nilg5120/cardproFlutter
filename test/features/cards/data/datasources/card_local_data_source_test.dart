import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/data/datasources/card_local_data_source.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CardLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    dataSource = CardLocalDataSourceImpl(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getCards groups placements per instance and keeps unassigned ones', () async {
    final effect = await db.into(db.cardEffects).insertReturning(
          CardEffectsCompanion.insert(
            name: 'Effect',
            description: 'Effect description',
          ),
        );

    final card = await db.into(db.mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Grouped Card',
            effectId: effect.id,
          ).copyWith(
            setName: const Value('Sample Set'),
          ),
        );

    final firstInstance = await db.into(db.cardInstances).insertReturning(
          CardInstancesCompanion.insert(
            cardId: card.id,
            description: const Value('First instance'),
          ),
        );

    final secondInstance = await db.into(db.cardInstances).insertReturning(
          CardInstancesCompanion.insert(
            cardId: card.id,
            description: const Value('Second instance'),
          ),
        );

    final firstContainer = await db.into(db.containers).insertReturning(
          ContainersCompanion.insert(
            containerType: 'deck',
          ).copyWith(
            name: const Value('Deck A'),
          ),
        );

    final secondContainer = await db.into(db.containers).insertReturning(
          ContainersCompanion.insert(
            containerType: 'binder',
          ).copyWith(
            name: const Value('Binder B'),
          ),
        );

    await db.into(db.containerCardLocations).insert(
          ContainerCardLocationsCompanion.insert(
            containerId: firstContainer.id,
            cardInstanceId: firstInstance.id,
            location: 'main',
          ),
        );

    await db.into(db.containerCardLocations).insert(
          ContainerCardLocationsCompanion.insert(
            containerId: secondContainer.id,
            cardInstanceId: firstInstance.id,
            location: 'side',
          ),
        );

    final cards = await dataSource.getCards();

    expect(cards, hasLength(2));

    final first = cards.firstWhere((c) => c.instance.id == firstInstance.id);
    expect(first.placements, hasLength(2));
    final summaries = first.placements
        .map((CardInstanceLocation placement) => (placement.containerName, placement.location))
        .toSet();
    expect(summaries, {
      ('Deck A', 'main'),
      ('Binder B', 'side'),
    });

    final second = cards.firstWhere((c) => c.instance.id == secondInstance.id);
    expect(second.placements, isEmpty);
  });
}
