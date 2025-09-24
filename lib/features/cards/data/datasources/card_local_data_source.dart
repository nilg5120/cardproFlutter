import 'dart:developer' as developer;

import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:drift/drift.dart';

abstract class CardLocalDataSource {
  /// カード一覧（カード定義と個体情報の組み合わせ）を取得する。
  Future<List<CardWithInstanceModel>> getCards();

  /// カードを追加し、必要に応じてマスタを新規作成しつつ個体を指定数量分作成する。
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

  /// 個体のメモのみを更新する。
  Future<void> editCard(CardInstanceModel instance, String description);

  /// カードの印刷情報（レアリティ/セット/カードNo.）と個体のメモを更新する。
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
    // 重複排除方針
    // 1) oracle_id で一意判定（コード生成に依存しないよう raw SQL を使用）
    // 2) 互換: oracle_id が不明な場合は name + setName + cardnumber で突合し、
    //    既存行が見つかれば oracle_id を後追いで補完する
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

    // レガシー照合: name/setName/cardnumber でも一致を確認し、
    // oracle_id 未設定の既存行があれば oracle_id を補完する
    if (existingCard == null) {
      final legacy = await (database.select(database.mtgCards)
            ..where((tbl) =>
                tbl.name.equals(name) &
                tbl.setName.equals(setName ?? '') &
                tbl.cardnumber.equals(cardNumber ?? 0)))
          .getSingleOrNull();
      if (legacy != null) {
        // 現在 NULL の場合のみ oracle_id を後追いで埋める
        await database.customStatement(
          'UPDATE mtg_cards SET oracle_id = ? WHERE id = ? AND oracle_id IS NULL',
          [oracleId, legacy.id],
        );
        existingCard = legacy;
      } else {
        // 既存名のみで一意に特定できる場合は oracle_id を補完する
        // 同名が複数ある場合はユニーク制約の都合でスキップする
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

    // 新規カードを挿入するか、既存カードの ID を流用する
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

    // 生成された Companion に依存せず、カードの oracle_id を確実に設定する
    if (existingCard == null) {
      await database.customStatement(
        'UPDATE mtg_cards SET oracle_id = ? WHERE id = ?',
        [oracleId, cardId],
      );
    } else {
      // 既存カードの名称が欠けていれば新しい値で補完する
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

    // カード個体を数量分挿入する（quantity <= 0 の場合は 1 件だけ挿入）
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

    // 直近で対象となったカード定義を取得する
    final card = await (database.select(database.mtgCards)
          ..where((tbl) => tbl.id.equals(cardId)))
        .getSingle();

    // 最後に挿入した個体とカード定義を結合したモデルを返す
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
    // カード（マスタ側）の印刷情報を更新する
    await (database.update(database.mtgCards)
          ..where((tbl) => tbl.id.equals(card.id)))
        .write(
      MtgCardsCompanion(
        rarity: Value(rarity),
        setName: Value(setName),
        cardnumber: Value(cardNumber),
      ),
    );

    // 個体（インスタンス）のメモと更新日時を更新する
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
