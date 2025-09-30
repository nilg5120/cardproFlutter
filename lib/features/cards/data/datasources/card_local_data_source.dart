import 'dart:developer' as developer;

import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:drift/drift.dart';

abstract class CardLocalDataSource {
  /// カード一覧�E�カード定義と個体情報の絁E��合わせ）を取得する、E
  Future<List<CardWithInstanceModel>> getCards();

  /// カードを追加し、忁E��に応じてマスタを新規作�Eしつつ個体を持E��数量�E作�Eする、E
  Future<CardWithInstanceModel> addCard({
    required String name,
    String? nameEn,
    String? nameJa,
    required String oracleId,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    String? lang,
    required int effectId,
    required String? description,
    required int quantity,
  });

  /// 個体を1件削除
  Future<void> deleteCard(CardInstanceModel instance);

  /// 個体�Eメモのみを更新する、E
  Future<void> editCard(
    CardInstanceModel instance,
    String description, {
    int? containerId,
  });

  /// カード�E印刷惁E���E�レアリチE��/セチE��/カードNo.�E�と個体�Eメモを更新する、E
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
    String? lang,
    required int effectId,
    required String? description,
    required int quantity,
  }) async {
    // 重褁E��除方釁E
    // 1) oracle_id で一意判定（コード生成に依存しなぁE��ぁEraw SQL を使用�E�E
    // 2) 互換: oracle_id が不�Eな場合�E name + setName + cardnumber で突合し、E
    //    既存行が見つかれば oracle_id を後追ぁE��補完すめE
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
    // oracle_id 未設定�E既存行があれば oracle_id を補完すめE
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
        // 既存名のみで一意に特定できる場合�E oracle_id を補完すめE
        // 同名が褁E��ある場合�Eユニ�Eク制紁E�E都合でスキチE�Eする
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

    // 新規カードを挿入するか、既存カード�E ID を流用する
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

    // 生�EされぁECompanion に依存せず、カード�E oracle_id を確実に設定すめE
    if (existingCard == null) {
      await database.customStatement(
        'UPDATE mtg_cards SET oracle_id = ? WHERE id = ?',
        [oracleId, cardId],
      );
    } else {
      // 既存カード�E名称が欠けてぁE��ば新しい値で補完すめE
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

    // カード個体を数量�E挿入する�E�Euantity <= 0 の場合�E 1 件だけ挿入�E�E
    CardInstance? lastInstance;
    final insertCount = (quantity <= 0) ? 1 : quantity;
    for (var i = 0; i < insertCount; i++) {
      lastInstance = await database
          .into(database.cardInstances)
          .insertReturning(
            CardInstancesCompanion.insert(
              cardId: cardId,
              lang: Value(lang),
              description: Value(description),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }

    // 直近で対象となったカード定義を取得すめE
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
  Future<void> editCard(
    CardInstanceModel instance,
    String description, {
    int? containerId,
  }) async {
    await database.transaction(() async {
      await (database.update(database.cardInstances)
            ..where((tbl) => tbl.id.equals(instance.id)))
          .write(
        CardInstancesCompanion(
          description: Value(description),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final existingPlacements = await (database.select(database.containerCardLocations)
            ..where((tbl) => tbl.cardInstanceId.equals(instance.id)))
          .get();

      if (containerId == null) {
        if (existingPlacements.isNotEmpty) {
          await (database.delete(database.containerCardLocations)
                ..where((tbl) => tbl.cardInstanceId.equals(instance.id)))
              .go();
        }
        return;
      }

      String? preservedLocation;
      for (final placement in existingPlacements) {
        if (placement.containerId == containerId) {
          preservedLocation = placement.location;
          break;
        }
      }

      if (existingPlacements.isNotEmpty) {
        await (database.delete(database.containerCardLocations)
              ..where((tbl) => tbl.cardInstanceId.equals(instance.id)))
            .go();
      }

      final location = preservedLocation ?? await _defaultLocationForContainer(containerId);

      await database.into(database.containerCardLocations).insert(
            ContainerCardLocationsCompanion.insert(
              containerId: containerId,
              cardInstanceId: instance.id,
              location: location,
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  Future<String> _defaultLocationForContainer(int containerId) async {
    final container = await (database.select(database.containers)
          ..where((tbl) => tbl.id.equals(containerId)))
        .getSingleOrNull();
    if (container == null) {
      return 'storage';
    }
    return container.containerType == 'deck' ? 'main' : 'storage';
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
    // カード（�Eスタ側�E��E印刷惁E��を更新する
    await (database.update(database.mtgCards)
          ..where((tbl) => tbl.id.equals(card.id)))
        .write(
      MtgCardsCompanion(
        rarity: Value(rarity),
        setName: Value(setName),
        cardnumber: Value(cardNumber),
      ),
    );

    // 個体（インスタンス�E��Eメモと更新日時を更新する
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
