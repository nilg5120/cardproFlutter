import 'package:cardpro/db/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

void main() {
  late AppDatabase db;

  ft.setUp(() {
    // 吁E��スト�EメモリDBでクリーンに開始すめE
    db = AppDatabase.test(NativeDatabase.memory());
  });

  ft.tearDown(() async {
    await db.close();
  });

  ft.test('カード�Eマスタと個体を挿入して取得できる', () async {
    // 外部キー用に効果を1件作�E
    final effect = await db.into(db.cardEffects).insertReturning(
          CardEffectsCompanion.insert(
            name: 'Basic',
            description: 'No special effect',
          ),
        );

    // マスタカードを挿入
    final card = await db.into(db.mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Test Card',
            rarity: const drift.Value('R'),
            setName: const drift.Value('Sample'),
            cardnumber: const drift.Value(123),
            effectId: effect.id,
          ),
        );

    // 個体カードを挿入
    await db.into(db.cardInstances).insert(
          CardInstancesCompanion.insert(
            cardId: card.id,
            lang: const Value('en'),
            description: const drift.Value('This is a test instance'),
          ),
        );

    // 検証
    final results = await db.getCardWithMaster();
    ft.expect(results.length, 1);
    final (fetchedCard, instance, location, container) = results.first;
    ft.expect(fetchedCard.name, 'Test Card');
    ft.expect(instance.description, 'This is a test instance');
    ft.expect(location, ft.isNull);
    ft.expect(container, ft.isNull);
  });

  ft.test('getCardWithMaster includes container placements via left join', () async {
    final effect = await db.into(db.cardEffects).insertReturning(
          CardEffectsCompanion.insert(
            name: 'Basic',
            description: 'No special effect',
          ),
        );

    final card = await db.into(db.mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Test Card',
            rarity: const drift.Value('R'),
            setName: const drift.Value('Sample'),
            cardnumber: const drift.Value(123),
            effectId: effect.id,
          ),
        );

    final instance = await db.into(db.cardInstances).insertReturning(
          CardInstancesCompanion.insert(
            cardId: card.id,
            description: const drift.Value('Instance with placement'),
          ),
        );

    final container = await db.into(db.containers).insertReturning(
          ContainersCompanion.insert(
            containerType: 'deck',
          ).copyWith(
            name: const drift.Value('Test Deck'),
            description: const drift.Value('Deck description'),
            isActive: const drift.Value(true),
          ),
        );

    await db.into(db.containerCardLocations).insert(
          ContainerCardLocationsCompanion.insert(
            containerId: container.id,
            cardInstanceId: instance.id,
            location: 'main',
          ),
        );

    final results = await db.getCardWithMaster();
    ft.expect(results.length, 1);
    final (
      fetchedCard,
      fetchedInstance,
      fetchedLocation,
      fetchedContainer,
    ) = results.first;

    ft.expect(fetchedCard.id, card.id);
    ft.expect(fetchedInstance.id, instance.id);
    ft.expect(fetchedLocation, ft.isNotNull);
    ft.expect(fetchedLocation!.containerId, container.id);
    ft.expect(fetchedLocation.location, 'main');
    ft.expect(fetchedContainer, ft.isNotNull);
    ft.expect(fetchedContainer!.name, 'Test Deck');
    ft.expect(fetchedContainer.containerType, 'deck');
  });
}
