import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/features/containers/presentation/pages/container_detail_page.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_bloc.dart';

class ContainerListItem extends StatelessWidget {
  final container_entity.Container container;
  final VoidCallback onDelete;

  const ContainerListItem({
    super.key,
    required this.container,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider<ContainerBloc>(
                create: (_) => sl<ContainerBloc>(),
                child: ContainerDetailPage(container: container),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      container.name ?? 'Container ${container.id}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('種類: ${container.containerType}') ,
                    if (container.description != null) ...[
                      const SizedBox(height: 4),
                      Text('説明: ${container.description}') ,
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('コンテナを削除'),
        content: const Text('このコンテナを削除しますか？カードの紐付けも削除されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('キャンセル')),
          TextButton(onPressed: () { Navigator.of(ctx).pop(); onDelete(); }, child: const Text('削除')),
        ],
      ),
    );
  }
}
