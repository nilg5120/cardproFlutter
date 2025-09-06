import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/core/di/injection_container.dart' as di;
import 'package:cardpro/features/home/presentation/pages/home_page.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CardBloc>(
          create: (_) => di.sl<CardBloc>()..add(GetCardsEvent()),
        ),
        BlocProvider<DeckBloc>(
          create: (_) => di.sl<DeckBloc>()..add(GetDecksEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'CardPro',
        theme: ThemeData(useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
