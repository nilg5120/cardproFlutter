import 'dart:io';

import 'package:cardpro/features/cards/data/models/card_model.dart';

/// Data source that imports card data from external files.
///
/// Expected file format:
///   - CSV (UTF-8)
///   - header: `name,rarity,setName,cardNumber,effectId,description`
/// Each record is validated before persistence.
///
/// Error handling:
///   - Invalid format or failed validation throws [ImportException].
///   - I/O errors are surfaced to the caller.
///
/// Retry strategy:
///   - Callers may invoke [retry] with exponential backoff (default 3 attempts).
abstract class ImportFileDataSource {
  /// Reads and validates the file, returning models ready for saving.
  ///
  /// Throws [ImportException] on format or validation errors.
  Future<List<CardModel>> parse(File file);

  /// Persists a batch of cards to storage.
  ///
  /// Throws [ImportException] when a write fails.
  Future<void> save(List<CardModel> cards);

  /// Executes [operation] with retry.
  ///
  /// The default implementation retries [maxAttempts] times using
  /// exponential backoff starting from [initialDelay].
  Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  });
}

/// Exception representing import specific failures.
class ImportException implements Exception {
  final String message;
  ImportException(this.message);

  @override
  String toString() => 'ImportException: $message';
}
