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
      'lang:ja name:${q}',
      'lang:ja ${q}',
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
