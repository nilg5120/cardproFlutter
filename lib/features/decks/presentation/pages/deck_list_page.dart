import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as deck_entity;
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';
import 'package:cardpro/core/di/injection_container.dart';

class DeckListPage extends StatelessWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DeckBloc>()..add(GetDecksEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('デッキ一覧'),
        ),
        body: BlocBuilder<DeckBloc, DeckState>(
          builder: (context, state) {
            if (state is DeckLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DeckLoaded) {
              return _buildDeckList(context, state.decks);
            } else if (state is DeckError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('デッキを読み込んでください'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDeckDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDeckList(BuildContext context, List<deck_entity.Container> decks) {
    if (decks.isEmpty) {
      return const Center(child: Text('デッキがありません'));
    }

    return ListView.builder(
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(deck.name ?? 'デッキ ${deck.id}'),
            subtitle: deck.description != null
                ? Text(deck.description!)
                : null,
            leading: const Icon(Icons.folder),
            onTap: () {
              // デッキの詳細画面に遷移する処理（今後実装予定）
            },
          ),
        );
      },
    );
  }

  void _showAddDeckDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    // BlocProviderの子ウィジェットからBlocを取得
    // FloatingActionButtonのonPressedコールバック内でのcontextはScaffoldのコンテキストであり、
    // BlocProviderの子ウィジェットのコンテキストではないため、直接取得できない
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        // 新しいBlocProviderを作成して、依存性注入コンテナからBlocを取得
        return BlocProvider(
          create: (_) => sl<DeckBloc>(),
          child: Builder(
            builder: (builderContext) {
              return AlertDialog(
                title: const Text('デッキを追加'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'デッキ名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: '説明',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        // 新しいコンテキストからBlocを取得
                        builderContext.read<DeckBloc>().add(
                          AddDeckEvent(
                            name: nameController.text,
                            description: descriptionController.text.isNotEmpty
                                ? descriptionController.text
                                : null,
                          ),
                        );
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text('追加'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

}
