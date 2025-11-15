import 'package:flutter/services.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';
import '../core/exceptions/app_exceptions.dart';

/// Service for clipboard operations
class ClipboardService {
  /// Copy text to clipboard
  static Future<Result<void>> copyToClipboard(String text) async {
    try {
      LoggerService.info('Copying text to clipboard');
      await Clipboard.setData(ClipboardData(text: text));
      LoggerService.info('Text copied successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to copy to clipboard', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to copy to clipboard', originalError: e),
      );
    }
  }

  /// Get text from clipboard
  static Future<Result<String>> getFromClipboard() async {
    try {
      LoggerService.info('Reading from clipboard');
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        LoggerService.info('Text retrieved from clipboard');
        return Result.success(data!.text!);
      }
      return Result.failure(ValidationException('No text in clipboard'));
    } catch (e, stackTrace) {
      LoggerService.error('Failed to read from clipboard', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to read from clipboard', originalError: e),
      );
    }
  }
}
