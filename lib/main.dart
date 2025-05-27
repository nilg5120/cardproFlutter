import 'package:flutter/material.dart';
import 'db/database.dart';
import 'card_list_page.dart';
import 'card_form_page.dart';
import 'deck_list_page.dart';


final db = AppDatabase();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardPro',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pages = [
    CardListPage(db: db),
    CardFormPage(db: db),
    DeckListPage(db: db),
    Placeholder(), // ここにデッキ/コンテナ一覧画面を追加予定
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'カード一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '追加',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'コンテナ',
          ),
        ],
      ),
    );
  }
}
