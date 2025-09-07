import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'card_list_page_test.mocks.dart';

// 本番のダイアログの代わりに用いる最小限のテスト用ダイアログ
class TestAddCardDialog extends StatelessWidget {
  const TestAddCardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Card'),
      content: const Text('Test dialog'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// FAB タップでテスト用ダイアログを開く最小ページ
class TestCardListPage extends StatelessWidget {
  const TestCardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: const Center(child: Text('Test page')),
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

  testWidgets('FAB タップで追加ダイアログが開く', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CardBloc>.value(
          value: mockBloc,
          child: const TestCardListPage(),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Add Card'), findsOneWidget);
  });
}
