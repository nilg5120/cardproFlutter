import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import 'db/database.dart';

// グローバルDBインスタンス（main.dart で定義されていることを前提）

class CardListPage extends StatefulWidget {
  final AppDatabase db;

  const CardListPage({super.key, required this.db});

  @override
  State<CardListPage> createState() => _CardListPageState();
}


class _CardListPageState extends State<CardListPage> {
  late Future<List<(PokemonCard, CardInstance)>> _cards;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _cards = widget.db.getCardWithMaster();
  }


  Future<void> _addCard() async {
      try {
    // マスターにすでに存在するかチェック
    final existing = await (widget.db.select(widget.db.pokemonCards)
          ..where((tbl) =>
              tbl.name.equals('ピカチュウ') &
              tbl.setName.equals('スカーレット') &
              tbl.cardnumber.equals(25)))
        .getSingleOrNull();

    final masterId = existing?.id ??
        (await widget.db.into(widget.db.pokemonCards).insertReturning(
              PokemonCardsCompanion.insert(
                name: 'ピカチュウ',
                rarity: drift.Value('C'),
                setName: drift.Value('スカーレット'),
                cardnumber: drift.Value(25),
              ),
            ))
            .id;

    // カード個体を登録
    await widget.db.into(widget.db.cardInstances).insert(CardInstancesCompanion.insert(
      cardId: masterId,
      description: drift.Value("初回版 ${DateTime.now()}"), // ✅ OK
    ));

    setState(() => _load());
      } catch (e, stack) {
    debugPrint('💥 エラー: $e');
    debugPrint('🔍 詳細: $stack');

      if (!mounted) return; // ← これを追加！
      
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('エラー発生'),
        content: Text(e.toString()),
      ),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('所持カード一覧')),
      body: FutureBuilder<List<(PokemonCard, CardInstance)>>(
        future: _cards,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('カードが登録されていません'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final (card, instance) = data[index];

              return ListTile(
                title: Text('${card.name} (#${card.cardnumber ?? "?"})'),
                subtitle: Text(instance.description ?? ''),
                trailing: Text(card.setName ?? ''),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
