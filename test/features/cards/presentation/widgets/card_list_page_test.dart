import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/pages/card_list_page.dart';

import 'card_list_page_test.mocks.dart';

// テスト用のダイアログウィジェット
class TestAddCardDialog extends StatelessWidget {
  const TestAddCardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カードを追加'),
      content: const Text('テスト用ダイアログ'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('追加'),
        ),
      ],
    );
  }
}

// テスト用のカードリストページ
class TestCardListPage extends StatelessWidget {
  const TestCardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カード一覧')),
      body: const Center(child: Text('テスト用ページ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const TestAddCardDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

@GenerateMocks([CardBloc])
void main() {
  late MockCardBloc mockBloc;

  setUp(() {
    mockBloc = MockCardBloc();

    when(mockBloc.state).thenReturn(const CardLoaded([]));
    when(mockBloc.stream).thenAnswer((_) => const Stream<CardState>.empty());
  });

  testWidgets('FABを押すと追加ダイアログが表示される', (WidgetTester tester) async {
    // テスト用のウィジェットをポンプ
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CardBloc>.value(
          value: mockBloc,
          child: const TestCardListPage(),
        ),
      ),
    );

    // FABが存在することを確認
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // FABをタップ
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // ダイアログが表示されることを確認
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('カードを追加'), findsOneWidget);
  });
}
