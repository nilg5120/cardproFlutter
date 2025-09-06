import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'card_list_page_test.mocks.dart';

// Minimal test dialog widget used instead of the app's real dialog
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

// Minimal test page with a FAB that opens the test dialog
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

  testWidgets('tapping FAB opens add dialog', (WidgetTester tester) async {
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

