import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/scryfall_card.dart';

class ScryfallApi {
  static const _base = 'https://api.scryfall.com';

  Future<List<String>> autocomplete(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    // include_multilingual=true で日本語名なども候補に含める
    final uri = Uri.parse('$_base/cards/autocomplete?q=${Uri.encodeQueryComponent(q)}&include_multilingual=true');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) return [];
    final body = json.decode(resp.body) as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? []).cast<String>();
    // 日本語入力時、より多くの日本語候補を補完するため search をフォールバック利用
    if (_looksJapanese(q)) {
      final ja = await _searchJapaneseNames(q);
      // 先頭に日本語候補を優先してマージ（重複除去）
      final set = <String>{};
      final merged = <String>[];
      for (final s in [...ja, ...list]) {
        if (set.add(s)) merged.add(s);
      }
      return merged.take(20).toList();
    }
    return list;
  }

  Future<ScryfallCard?> getCardByExactName(String name) async {
    final q = name.trim();
    if (q.isEmpty) return null;
    // まず英語名として exact を試す
    final exact = Uri.parse('$_base/cards/named?exact=${Uri.encodeQueryComponent(q)}');
    final exactResp = await http.get(exact).timeout(const Duration(seconds: 10));
    if (exactResp.statusCode == 200) {
      final body = json.decode(exactResp.body) as Map<String, dynamic>;
      return ScryfallCard.fromJson(body);
    }
    // 日本語など多言語名の可能性がある場合は検索へフォールバック
    // name:"..." に完全一致、言語は特定せず（最初のヒットを採用）
    final query = 'name:"$q"';
    final search = Uri.parse('$_base/cards/search?q=${Uri.encodeQueryComponent(query)}&unique=prints&order=released');
    final searchResp = await http.get(search).timeout(const Duration(seconds: 10));
    if (searchResp.statusCode != 200) return null;
    final body = json.decode(searchResp.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>?;
    if (data == null || data.isEmpty) return null;
    return ScryfallCard.fromJson(data.first as Map<String, dynamic>);
  }

  Future<List<ScryfallCard>> listPrintings(String name) async {
    final q = name.trim();
    if (q.isEmpty) return [];
    Uri uri;
    if (_looksJapanese(q)) {
      // 日本語入力: 日本語ローカライズの刷りを優先
      final query = 'lang:ja name:"$q"';
      uri = Uri.parse('${ScryfallApi._base}/cards/search?q=${Uri.encodeQueryComponent(query)}&unique=prints&order=released');
    } else {
      // 英語名でそのカード名の刷りを一覧（厳密一致）
      uri = Uri.parse('${ScryfallApi._base}/cards/search?q=${Uri.encodeQueryComponent('!"$q"')}&unique=prints&order=released');
    }
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) return [];
    final body = json.decode(resp.body) as Map<String, dynamic>;
    final data = (body['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ScryfallCard.fromJson(e))
        .toList();
    return data;
  }
}

bool _looksJapanese(String s) {
  // ひらがな、カタカナ、CJK のいずれかが含まれていれば日本語とみなす
  return RegExp(r'[\u3040-\u30FF\u4E00-\u9FFF]').hasMatch(s);
}

extension _SearchJa on ScryfallApi {
  Future<List<String>> _searchJapaneseNames(String q) async {
    // lang:ja を付けて検索。name: フィールドにもかけるが、printed_name が返るので前方一致・部分一致を許容
    final queries = [
      'lang:ja name:$q',
      'lang:ja $q',
    ];
    final results = <String>[];
    for (final part in queries) {
      final uri = Uri.parse('${ScryfallApi._base}/cards/search?q=${Uri.encodeQueryComponent(part)}&order=name&unique=cards');
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) continue;
      final body = json.decode(resp.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      for (final c in data) {
        String? name = c['printed_name'] as String?;
        if (name == null) {
          // 一部は faces に printed_name が入る
          final faces = c['card_faces'];
          if (faces is List && faces.isNotEmpty) {
            final face0 = faces.first;
            if (face0 is Map && face0['printed_name'] is String) {
              name = face0['printed_name'] as String;
            }
          }
        }
        name ??= c['name'] as String?; // 最後の手段: 英語名
        if (name != null) results.add(name);
      }
      if (results.isNotEmpty) break; // どちらかでヒットしたら十分
    }
    // 入力に含まれる文字列で軽くフィルタ
    final qn = q.toLowerCase();
    final dedup = <String>{};
    final out = <String>[];
    for (final s in results) {
      if (!dedup.add(s)) continue;
      if (s.toLowerCase().contains(qn)) out.add(s);
    }
    return out.take(20).toList();
  }
}
class LocalizedNames {
  final String en;
  final String? ja;
  const LocalizedNames(this.en, this.ja);
}

extension LocalizedByOracle on ScryfallApi {
  /// Returns English and Japanese names for a card identified by oracle_id.
  /// If no Japanese print exists, `ja` will be null.
  Future<LocalizedNames?> getLocalizedNamesByOracleId(String oracleId) async {
    try {
      // English name (Scryfall's `name` is the oracle English name)
      final enUri = Uri.parse('${ScryfallApi._base}/cards/search?q=${Uri.encodeQueryComponent('oracleid:$oracleId')}&unique=cards&order=released');
      final enResp = await http.get(enUri).timeout(const Duration(seconds: 10));
      if (enResp.statusCode != 200) return null;
      final enBody = json.decode(enResp.body) as Map<String, dynamic>;
      final enData = (enBody['data'] as List<dynamic>?);
      if (enData == null || enData.isEmpty) return null;
      final enName = (enData.first as Map<String, dynamic>)['name'] as String? ?? '';

      // Japanese printed name, if any
      String? jaName;
      final jaUri = Uri.parse('${ScryfallApi._base}/cards/search?q=${Uri.encodeQueryComponent('oracleid:$oracleId lang:ja')}&unique=prints&order=released');
      final jaResp = await http.get(jaUri).timeout(const Duration(seconds: 10));
      if (jaResp.statusCode == 200) {
        final jaBody = json.decode(jaResp.body) as Map<String, dynamic>;
        final jaData = (jaBody['data'] as List<dynamic>?);
        if (jaData != null && jaData.isNotEmpty) {
          final first = jaData.first as Map<String, dynamic>;
          jaName = first['printed_name'] as String?;
          if (jaName == null) {
            final faces = first['card_faces'];
            if (faces is List && faces.isNotEmpty) {
              final face0 = faces.first;
              if (face0 is Map && face0['printed_name'] is String) {
                jaName = face0['printed_name'] as String;
              }
            }
          }
        }
      }

      return LocalizedNames(enName, jaName);
    } catch (_) {
      return null;
    }
  }
}
