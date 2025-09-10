class ScryfallCard {
  final String name; // English oracle name
  final String? printedName; // Localized printed name (e.g., Japanese)
  final String? setCode; // e.g., "lea"
  final String? setName; // e.g., "Limited Edition Alpha"
  final String? collectorNumber; // can include letters, e.g., "101a"
  final String? rarity; // common, uncommon, rare, mythic, etc.
  final String? lang; // "en", "ja", etc.
  final String? releasedAt; // yyyy-mm-dd
  final String oracleId; // Scryfall oracle_id (same across languages/prints)

  ScryfallCard({
    required this.name,
    this.printedName,
    this.setCode,
    this.setName,
    this.collectorNumber,
    this.rarity,
    this.lang,
    this.releasedAt,
    required this.oracleId,
  });

  factory ScryfallCard.fromJson(Map<String, dynamic> json) {
    return ScryfallCard(
      name: json['name'] as String? ?? '',
      printedName: json['printed_name'] as String?,
      setCode: json['set'] as String?,
      setName: json['set_name'] as String?,
      collectorNumber: json['collector_number'] as String?,
      rarity: json['rarity'] as String?,
      lang: json['lang'] as String?,
      releasedAt: json['released_at'] as String?,
      oracleId: json['oracle_id'] as String? ?? '',
    );
  }

  int? get collectorNumberInt {
    if (collectorNumber == null) return null;
    // Extract leading digits so that values like "101a" become 101
    final match = RegExp(r'^(\d+)').firstMatch(collectorNumber!);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  String displayTitle() {
    final display = printedName?.isNotEmpty == true ? printedName! : name;
    final setInfo = setName ?? setCode ?? '';
    final num = collectorNumber ?? '';
    final langDisp = (lang != null && lang != 'en') ? ' • ${lang!.toUpperCase()}' : '';
    return [display, if (setInfo.isNotEmpty) '($setInfo)', if (num.isNotEmpty) '#$num']
            .join(' ') + langDisp;
  }

  String? get rarityShort {
    switch (rarity) {
      case 'common':
        return 'C';
      case 'uncommon':
        return 'U';
      case 'rare':
        return 'R';
      case 'mythic':
        return 'M';
      default:
        return rarity;
    }
  }
}
