import 'dart:developer' as developer;

import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:drift/drift.dart';

abstract class CardLocalDataSource {
  /// カード一覧�E�カード定義 + 個体）を取征E
  Future<List<CardWithInstanceModel>> getCards();

  /// カードを追加�E�忁E��に応じてマスタ新規作�Eし、個体を数量�E作�E�E�E
  Future<CardWithInstanceModel> addCard({
    required String name,
    String? nameEn,
    String? nameJa,
    required String oracleId,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required int effectId,
    required String? description,
    required int quantity,
  });

  /// 個体を1件削除
  Future<void> deleteCard(CardInstanceModel instance);

  /// 個体�Eメモのみ更新
  Future<void> editCard(CardInstanceModel instance, String description);

  /// カード�E印刷惁E���E�Earity/Set/Card No.�E�と個体�Eメモを更新
  Future<void> editCardFull({
    required CardModel card,
    required CardInstanceModel instance,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required String? description,
  });
}

class CardLocalDataSourceImpl implements CardLocalDataSource {
  final AppDatabase database;

  CardLocalDataSourceImpl({required this.database});

  @override
  Future<List<CardWithInstanceModel>> getCards() async {
    developer.log('Fetching card data', name: 'CardLocalDataSource');
    final results = await database.getCardWithMaster();
    developer.log('Fetched cards: ${results.length}', name: 'CardLocalDataSource');

    final grouped = <int, _CardInstanceGroup>{};

    for (final (card, instance, location, container) in results) {
      final group = grouped.putIfAbsent(
        instance.id,
        () => _CardInstanceGroup(card: card, instance: instance),
      );

      if (location != null) {
        group.placements.add(
          CardInstanceLocation(
            containerId: location.containerId,
            location: location.location,
            containerName: container?.name,
            containerDescription: container?.description,
            containerType: container?.containerType,
            isActive: container?.isActive,
          ),
        );
      }
    }

    final cardModels = grouped.values
        .map(
          (group) => CardWithInstanceModel.fromDrift(
            group.card,
            group.instance,
            placements: List.unmodifiable(group.placements),
          ),
        )
        .toList();

    developer.log('Converted to models: ${cardModels.length}', name: 'CardLocalDataSource');
    return cardModels;
  }

  @override
  Future<CardWithInstanceModel> addCard({
    required String name,
    String? nameEn,
    String? nameJa,
    required String oracleId,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required int effectId,
    required String? description,
    required int quantity,
  }) async {
    // 重褁E��除方釁E
    // 1) oracle_id で一意判定（コード生成に依存せぁEraw SQL を使用�E�E
    // 2) 互換: oracle_id が不�Eな場合�E name + setName + cardnumber で突合し、E
    //    既存行が見つかれば oracle_id を後追ぁE��補宁E
    final byOracle = await database
        .customSelect(
          'SELECT id FROM mtg_cards WHERE oracle_id = ? LIMIT 1',
          variables: [Variable.withString(oracleId)],
        )
        .getSingleOrNull();
    MtgCard? existingCard;
    if (byOracle != null) {
      final id = byOracle.read<int>('id');
      existingCard = await (database.select(database.mtgCards)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
    }

    // レガシー照吁E name/setName/cardnumber でも一致を確認し、E
    // oracle_id 未設定�E既存行があれば oracle_id を補宁E
    if (existingCard == null) {
      final legacy = await (database.select(database.mtgCards)
            ..where((tbl) =>
                tbl.name.equals(name) &
                tbl.setName.equals(setName ?? '') &
                tbl.cardnumber.equals(cardNumber ?? 0)))
          .getSingleOrNull();
      if (legacy != null) {
        // 現在 NULL の場合�Eみ oracle_id を後追ぁE��埋めめE
        await database.customStatement(
          'UPDATE mtg_cards SET oracle_id = ? WHERE id = ? AND oracle_id IS NULL',
          [oracleId, legacy.id],
        );
        existingCard = legacy;
      } else {
        // 既存名のみで一意に特定できる場合�E oracle_id を補宁E
        // 同名が褁E��ある場合�Eユニ�Eク制紁E�E都合でスキチE�E
        final sameName = await (database.select(database.mtgCards)
              ..where((t) => t.name.equals(name)))
            .get();
        if (sameName.length == 1) {
          final only = sameName.first;
          await database.customStatement(
            'UPDATE mtg_cards SET oracle_id = ? WHERE id = ? AND oracle_id IS NULL',
            [oracleId, only.id],
          );
          existingCard = only;
        }
      }
    }

    // 新規カードを挿入、もしくは既存カード�E ID を流用
    final cardId = existingCard?.id ??
        (await database.into(database.mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: name,
            effectId: effectId,
          ).copyWith(
            rarity: Value(rarity),
            setName: Value(setName),
            cardnumber: Value(cardNumber),
            nameEn: Value(nameEn),
            nameJa: Value(nameJa),
          ),
        )).id;

    // 生�EされぁECompanion に依存せず、カード�E oracle_id を確実に設宁E
    if (existingCard == null) {
      await database.customStatement(
        'UPDATE mtg_cards SET oracle_id = ? WHERE id = ?',
        [oracleId, cardId],
      );
    } else {
      // Optionally fill names if missing on existing card
      if ((existingCard.nameEn == null || existingCard.nameEn!.isEmpty) && (nameEn != null && nameEn.isNotEmpty)) {
        await database.customStatement(
          'UPDATE mtg_cards SET name_en = ? WHERE id = ? AND (name_en IS NULL OR name_en = "")',
          [nameEn, existingCard.id],
        );
      }
      if ((existingCard.nameJa == null || existingCard.nameJa!.isEmpty) && (nameJa != null && nameJa.isNotEmpty)) {
        await database.customStatement(
          'UPDATE mtg_cards SET name_ja = ? WHERE id = ? AND (name_ja IS NULL OR name_ja = "")',
          [nameJa, existingCard.id],
        );
      }
    }

    // カード個体を数量�E挿入�E�Euantity <= 0 の場合�E 1�E�E
    CardInstance? lastInstance;
    final insertCount = (quantity <= 0) ? 1 : quantity;
    for (var i = 0; i < insertCount; i++) {
      lastInstance = await database
          .into(database.cardInstances)
          .insertReturning(
            CardInstancesCompanion.insert(
              cardId: cardId,
              description: Value(description),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }

    // 直近で対象となったカード定義を取征E
    final card = await (database.select(database.mtgCards)
          ..where((tbl) => tbl.id.equals(cardId)))
        .getSingle();

    // 最後に挿入した個体とカード定義を結合したモチE��を返す
    return CardWithInstanceModel.fromDrift(card, lastInstance!);
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

  @override
  Future<void> editCardFull({
    required CardModel card,
    required CardInstanceModel instance,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required String? description,
  }) async {
    // カード（�Eスタ�E��E印刷惁E��を更新
    await (database.update(database.mtgCards)
          ..where((tbl) => tbl.id.equals(card.id)))
        .write(
      MtgCardsCompanion(
        rarity: Value(rarity),
        setName: Value(setName),
        cardnumber: Value(cardNumber),
      ),
    );

    // 個体（インスタンス�E��Eメモ・更新日時を更新
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

class _CardInstanceGroup {
  final MtgCard card;
  final CardInstance instance;
  final List<CardInstanceLocation> placements;

  _CardInstanceGroup({
    required this.card,
    required this.instance,
  }) : placements = [];
}
