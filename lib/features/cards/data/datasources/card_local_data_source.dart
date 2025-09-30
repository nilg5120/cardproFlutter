import 'dart:developer' as developer;

import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:drift/drift.dart';

abstract class CardLocalDataSource {
  /// 繧ｫ繝ｼ繝我ｸ隕ｧ・医き繝ｼ繝牙ｮ夂ｾｩ縺ｨ蛟倶ｽ捺ュ蝣ｱ縺ｮ邨・∩蜷医ｏ縺幢ｼ峨ｒ蜿門ｾ励☆繧九・
  Future<List<CardWithInstanceModel>> getCards();

  /// 繧ｫ繝ｼ繝峨ｒ霑ｽ蜉縺励∝ｿ・ｦ√↓蠢懊§縺ｦ繝槭せ繧ｿ繧呈眠隕丈ｽ懈・縺励▽縺､蛟倶ｽ薙ｒ謖・ｮ壽焚驥丞・菴懈・縺吶ｋ縲・
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

  /// 蛟倶ｽ薙ｒ1莉ｶ蜑企勁
  Future<void> deleteCard(CardInstanceModel instance);

  /// 蛟倶ｽ薙・繝｡繝｢縺ｮ縺ｿ繧呈峩譁ｰ縺吶ｋ縲・
  Future<void> editCard(
    CardInstanceModel instance,
    String description, {
    int? containerId,
  });

  /// 繧ｫ繝ｼ繝峨・蜊ｰ蛻ｷ諠・ｱ・医Ξ繧｢繝ｪ繝・ぅ/繧ｻ繝・ヨ/繧ｫ繝ｼ繝丑o.・峨→蛟倶ｽ薙・繝｡繝｢繧呈峩譁ｰ縺吶ｋ縲・
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
    // 驥崎､・賜髯､譁ｹ驥・
    // 1) oracle_id 縺ｧ荳諢丞愛螳夲ｼ医さ繝ｼ繝臥函謌舌↓萓晏ｭ倥＠縺ｪ縺・ｈ縺・raw SQL 繧剃ｽｿ逕ｨ・・
    // 2) 莠呈鋤: oracle_id 縺御ｸ肴・縺ｪ蝣ｴ蜷医・ name + setName + cardnumber 縺ｧ遯∝粋縺励・
    //    譌｢蟄倩｡後′隕九▽縺九ｌ縺ｰ oracle_id 繧貞ｾ瑚ｿｽ縺・〒陬懷ｮ後☆繧・
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

    // 繝ｬ繧ｬ繧ｷ繝ｼ辣ｧ蜷・ name/setName/cardnumber 縺ｧ繧ゆｸ閾ｴ繧堤｢ｺ隱阪＠縲・
    // oracle_id 譛ｪ險ｭ螳壹・譌｢蟄倩｡後′縺ゅｌ縺ｰ oracle_id 繧定｣懷ｮ後☆繧・
    if (existingCard == null) {
      final legacy = await (database.select(database.mtgCards)
            ..where((tbl) =>
                tbl.name.equals(name) &
                tbl.setName.equals(setName ?? '') &
                tbl.cardnumber.equals(cardNumber ?? 0)))
          .getSingleOrNull();
      if (legacy != null) {
        // 迴ｾ蝨ｨ NULL 縺ｮ蝣ｴ蜷医・縺ｿ oracle_id 繧貞ｾ瑚ｿｽ縺・〒蝓九ａ繧・
        await database.customStatement(
          'UPDATE mtg_cards SET oracle_id = ? WHERE id = ? AND oracle_id IS NULL',
          [oracleId, legacy.id],
        );
        existingCard = legacy;
      } else {
        // 譌｢蟄伜錐縺ｮ縺ｿ縺ｧ荳諢上↓迚ｹ螳壹〒縺阪ｋ蝣ｴ蜷医・ oracle_id 繧定｣懷ｮ後☆繧・
        // 蜷悟錐縺瑚､・焚縺ゅｋ蝣ｴ蜷医・繝ｦ繝九・繧ｯ蛻ｶ邏・・驛ｽ蜷医〒繧ｹ繧ｭ繝・・縺吶ｋ
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

    // 譁ｰ隕上き繝ｼ繝峨ｒ謖ｿ蜈･縺吶ｋ縺九∵里蟄倥き繝ｼ繝峨・ ID 繧呈ｵ∫畑縺吶ｋ
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

    // 逕滓・縺輔ｌ縺・Companion 縺ｫ萓晏ｭ倥○縺壹√き繝ｼ繝峨・ oracle_id 繧堤｢ｺ螳溘↓險ｭ螳壹☆繧・
    if (existingCard == null) {
      await database.customStatement(
        'UPDATE mtg_cards SET oracle_id = ? WHERE id = ?',
        [oracleId, cardId],
      );
    } else {
      // 譌｢蟄倥き繝ｼ繝峨・蜷咲ｧｰ縺梧ｬ縺代※縺・ｌ縺ｰ譁ｰ縺励＞蛟､縺ｧ陬懷ｮ後☆繧・
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

    // 繧ｫ繝ｼ繝牙倶ｽ薙ｒ謨ｰ驥丞・謖ｿ蜈･縺吶ｋ・・uantity <= 0 縺ｮ蝣ｴ蜷医・ 1 莉ｶ縺縺第諺蜈･・・
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

    // 逶ｴ霑代〒蟇ｾ雎｡縺ｨ縺ｪ縺｣縺溘き繝ｼ繝牙ｮ夂ｾｩ繧貞叙蠕励☆繧・
    final card = await (database.select(database.mtgCards)
          ..where((tbl) => tbl.id.equals(cardId)))
        .getSingle();

    // 譛蠕後↓謖ｿ蜈･縺励◆蛟倶ｽ薙→繧ｫ繝ｼ繝牙ｮ夂ｾｩ繧堤ｵ仙粋縺励◆繝｢繝・Ν繧定ｿ斐☆
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
    // 繧ｫ繝ｼ繝会ｼ医・繧ｹ繧ｿ蛛ｴ・峨・蜊ｰ蛻ｷ諠・ｱ繧呈峩譁ｰ縺吶ｋ
    await (database.update(database.mtgCards)
          ..where((tbl) => tbl.id.equals(card.id)))
        .write(
      MtgCardsCompanion(
        rarity: Value(rarity),
        setName: Value(setName),
        cardnumber: Value(cardNumber),
      ),
    );

    // 蛟倶ｽ難ｼ医う繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ・峨・繝｡繝｢縺ｨ譖ｴ譁ｰ譌･譎ゅｒ譖ｴ譁ｰ縺吶ｋ
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
