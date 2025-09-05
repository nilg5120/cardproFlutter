import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:cardpro/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('カードを登録して取得できる', () async {
    // マスター登録
    final cardId = await db.into(db.mtgCards).insertReturning(
      MtgCardsCompanion.insert(
        name: 'テストカード',
        rarity: const Value('R'),
        setName: const Value('サンプル'),
        cardnumber: const Value(123),
        //TODO: effectId は後で実装する
        effectId: 0, // 仮の値
      ),
    );

    // 個体登録
    await db.into(db.cardInstances).insert(
      CardInstancesCompanion.insert(
        cardId: cardId.id,
        description: const Value('これはテスト個体'),
      ),
    );

    // 結果検証
    final results = await db.getCardWithMaster();
    expect(results.length, 1);
    final (card, instance) = results.first;
    expect(card.name, 'テストカード');
    expect(instance.description, 'これはテスト個体');
  });
}
