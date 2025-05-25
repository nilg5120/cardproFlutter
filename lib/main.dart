import 'package:flutter/material.dart';
import 'db/database.dart';
import 'card_list_page.dart';


void main() {
  runApp(const MyApp());
}

final db = AppDatabase();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardPro',
      theme: ThemeData(useMaterial3: true),
      home: const CardListPage(),
    );
  }
}
