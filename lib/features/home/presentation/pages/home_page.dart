import 'package:flutter/material.dart';

import 'package:cardpro/features/cards/presentation/pages/card_list_page.dart';
import 'package:cardpro/features/decks/presentation/pages/deck_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavTile(
            icon: Icons.view_list,
            title: 'カード一覧',
            subtitle: '登録済みのカードを表示・編集',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _NavTile(
            icon: Icons.folder,
            title: 'デッキ一覧',
            subtitle: 'デッキを確認・編集',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeckListPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
