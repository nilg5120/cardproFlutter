import 'package:flutter/material.dart';

import 'package:cardpro/features/cards/presentation/pages/card_list_page.dart';
import 'package:cardpro/features/decks/presentation/pages/deck_list_page.dart';
import 'package:cardpro/features/containers/presentation/pages/container_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    CardListPage(),
    DeckListPage(),
    ContainerListPage(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.view_list),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder),
            label: 'Decks',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Containers',
          ),
        ],
      ),
    );
  }
}
