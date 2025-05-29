import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/core/di/injection_container.dart';

class CardFormPage extends StatefulWidget {
  const CardFormPage({super.key});

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<CardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rarityController = TextEditingController();
  final _setNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedEffectId = 1; // デフォルト値

  @override
  void dispose() {
    _nameController.dispose();
    _rarityController.dispose();
    _setNameController.dispose();
    _cardNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CardBloc>(),
      child: BlocListener<CardBloc, CardState>(
        listener: (context, state) {
          if (state is CardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CardLoaded) {
            _resetForm();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('カードを追加しました')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('カード追加'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'カード名',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'カード名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rarityController,
                    decoration: const InputDecoration(
                      labelText: 'レアリティ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _setNameController,
                    decoration: const InputDecoration(
                      labelText: 'セット名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'カード番号',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedEffectId,
                    decoration: const InputDecoration(
                      labelText: 'カード効果',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('通常'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('特殊能力'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('サポート'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedEffectId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'メモ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('カードを追加'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final cardNumber = _cardNumberController.text.isNotEmpty
          ? int.tryParse(_cardNumberController.text)
          : null;

      context.read<CardBloc>().add(
            AddCardEvent(
              name: _nameController.text,
              rarity: _rarityController.text.isNotEmpty
                  ? _rarityController.text
                  : null,
              setName: _setNameController.text.isNotEmpty
                  ? _setNameController.text
                  : null,
              cardNumber: cardNumber,
              effectId: _selectedEffectId,
              description: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
            ),
          );
    }
  }

  void _resetForm() {
    _nameController.clear();
    _rarityController.clear();
    _setNameController.clear();
    _cardNumberController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedEffectId = 1;
    });
  }
}
