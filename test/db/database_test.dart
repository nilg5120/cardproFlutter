import 'package:cardpro/db/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insert and fetch a card with instance', () async {
    // ensure an effect exists for FK
    final effect = await db.into(db.cardEffects).insertReturning(
          CardEffectsCompanion.insert(
            name: 'Basic',
            description: 'No special effect',
          ),
        );

    // insert master
    final card = await db.into(db.mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Test Card',
            rarity: const Value('R'),
            setName: const Value('Sample'),
            cardnumber: const Value(123),
            effectId: effect.id,
          ),
        );

    // insert instance
    await db.into(db.cardInstances).insert(
          CardInstancesCompanion.insert(
            cardId: card.id,
            description: const Value('This is a test instance'),
          ),
        );

    // verify
    final results = await db.getCardWithMaster();
    expect(results.length, 1);
    final (fetchedCard, instance) = results.first;
    expect(fetchedCard.name, 'Test Card');
    expect(instance.description, 'This is a test instance');
  });
}

