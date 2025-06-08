import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/pages/card_list_page.dart';

import 'card_list_page_test.mocks.dart';

@GenerateMocks([CardBloc])
void main() {
  late MockCardBloc mockBloc;

  setUp(() {
    mockBloc = MockCardBloc();

    when(mockBloc.state).thenReturn(const CardLoaded([]));
    when(mockBloc.stream).thenAnswer((_) => const Stream<CardState>.empty());
  });

  testWidgets('FABを押すと追加ダイアログが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CardBloc>.value(
          value: mockBloc,
          child: const CardListPage(),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('カードを追加'), findsOneWidget);
  });
}
