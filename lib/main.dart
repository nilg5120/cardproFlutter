import 'package:flutter/material.dart';
import 'package:cardpro/core/di/injection_container.dart' as di;
import 'package:cardpro/features/cards/presentation/pages/card_list_page.dart';
import 'package:cardpro/features/cards/presentation/pages/card_form_page.dart';
import 'package:cardpro/features/decks/presentation/pages/deck_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
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
    const CardListPage(),
    const CardFormPage(),
    const DeckListPage(),
    const Placeholder(), // ここにデッキ/コンテナ一覧画面を追加予定
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
