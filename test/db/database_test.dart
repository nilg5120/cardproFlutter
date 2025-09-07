import 'package:cardpro/db/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // 各テストはメモリDBでクリーンに開始する
    db = AppDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('カードのマスタと個体を挿入して取得できる', () async {
    // 外部キー用に効果を1件作成
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
            rarity: const Value('R'),
            setName: const Value('Sample'),
            cardnumber: const Value(123),
            effectId: effect.id,
          ),
        );

    // 個体カードを挿入
    await db.into(db.cardInstances).insert(
          CardInstancesCompanion.insert(
            cardId: card.id,
            description: const Value('This is a test instance'),
          ),
        );

    // 検証
    final results = await db.getCardWithMaster();
    expect(results.length, 1);
    final (fetchedCard, instance) = results.first;
    expect(fetchedCard.name, 'Test Card');
    expect(instance.description, 'This is a test instance');
  });
}
