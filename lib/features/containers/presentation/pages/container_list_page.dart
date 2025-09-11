import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_bloc.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_event.dart';
import 'package:cardpro/features/containers/presentation/widgets/container_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContainerListPage extends StatelessWidget {
  const ContainerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContainerBloc>()..add(GetContainersEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('コンテナ一覧'),
        ),
        body: BlocBuilder<ContainerBloc, ContainerState>(
          builder: (context, state) {
            if (state is ContainerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContainerLoaded) {
              if (state.containers.isEmpty) {
                return const Center(child: Text('コンテナがありません'));
              }
              return ListView.builder(
                itemCount: state.containers.length,
                itemBuilder: (context, index) {
                  final c = state.containers[index];
                  return ContainerListItem(
                    container: c,
                    onDelete: () => context
                        .read<ContainerBloc>()
                        .add(DeleteContainerEvent(id: c.id)),
                  );
                },
              );
            } else if (state is ContainerError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('読み込み中'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'containers_fab_list',
          onPressed: () => _showAddContainerDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddContainerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('コンテナを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '名称（例: 押し入れA）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: '種類（drawer, binder など）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明（任意）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                final name = nameController.text.trim();
                final type = typeController.text.trim();
                final desc = descriptionController.text.trim();
                if (name.isNotEmpty && type.isNotEmpty) {
                  context.read<ContainerBloc>().add(
                        AddContainerEvent(
                          name: name,
                          containerType: type,
                          description: desc.isEmpty ? null : desc,
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
    );
  }
}
