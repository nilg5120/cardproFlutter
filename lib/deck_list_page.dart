import 'package:flutter/material.dart';
import 'db/database.dart' as db_package; // ← これを追加
import 'deck_form_page.dart';
class DeckListPage extends StatefulWidget {
  final db_package.AppDatabase db;


  const DeckListPage({super.key, required this.db});

  @override
  State<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  late Future<List<db_package.Container>> _decks;


  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _decks = (widget.db.select(widget.db.containers)
          ..where((tbl) => tbl.containerType.equals('deck')))
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('デッキ一覧')),
      body: FutureBuilder(
        future: _decks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final decks = snapshot.data!;
          if (decks.isEmpty) {
            return const Center(child: Text('デッキが登録されていません'));
          }

          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return ListTile(
                title: Text(deck.name ?? '(無名デッキ)'),
                subtitle: Text(deck.description ?? ''),
                trailing: ElevatedButton(
                  onPressed: () {
                    // TODO: デッキを「使用する」処理を書く
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${deck.name ?? 'このデッキ'} を使用しました')),
                    );
                  },
                  child: const Text('使用'),
                ),
              );
            },
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DeckFormPage(db: widget.db)),
          ).then((_) => setState(_load)); // ✅ 戻ってきたら再読み込み
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
