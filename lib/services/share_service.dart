import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';
import '../core/exceptions/app_exceptions.dart';

/// Service for sharing messages
class ShareService {
  /// Share message using native share dialog
  static Future<Result<void>> shareMessage(MessageModel message) async {
    try {
      LoggerService.info('Sharing message via native dialog');
      
      final text = '''
${message.generatedText}

---
📱 Generated with AI Mood
💝 For ${message.recipientType} • ${message.tone}
''';

      await Share.share(
        text,
        subject: 'Message from AI Mood',
      );
      
      LoggerService.info('Share dialog opened successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share message', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to share message', originalError: e),
      );
    }
  }

  /// Share message text only
  static Future<Result<void>> shareText(String text) async {
    try {
      LoggerService.info('Sharing text');
      await Share.share(text);
      LoggerService.info('Text shared successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share text', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to share text', originalError: e),
      );
    }
  }

  /// Share to WhatsApp
  static Future<Result<void>> shareToWhatsApp(String text) async {
    try {
      LoggerService.info('Sharing to WhatsApp');
      
      final encodedText = Uri.encodeComponent(text);
      final whatsappUrl = 'https://wa.me/?text=$encodedText';
      
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        LoggerService.info('WhatsApp opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(
          ValidationException('WhatsApp is not installed'),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share to WhatsApp', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to open WhatsApp', originalError: e),
      );
    }
  }

  /// Share to Twitter
  static Future<Result<void>> shareToTwitter(String text) async {
    try {
      LoggerService.info('Sharing to Twitter');
      
      final encodedText = Uri.encodeComponent('$text\n\n#AIMood #AIGenerated');
      final twitterUrl = 'https://twitter.com/intent/tweet?text=$encodedText';
      
      final uri = Uri.parse(twitterUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        LoggerService.info('Twitter opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(
          ValidationException('Could not open Twitter'),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share to Twitter', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to open Twitter', originalError: e),
      );
    }
  }

  /// Share to SMS
  static Future<Result<void>> shareToSMS(String text) async {
    try {
      LoggerService.info('Sharing via SMS');
      
      final encodedText = Uri.encodeComponent(text);
      final smsUrl = 'sms:?body=$encodedText';
      
      final uri = Uri.parse(smsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        LoggerService.info('SMS app opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(
          ValidationException('Could not open SMS app'),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share to SMS', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to open SMS app', originalError: e),
      );
    }
  }

  /// Share to Email
  static Future<Result<void>> shareToEmail(String text, {String? subject}) async {
    try {
      LoggerService.info('Sharing via Email');
      
      final encodedSubject = Uri.encodeComponent(subject ?? 'Message from AI Mood');
      final encodedBody = Uri.encodeComponent(text);
      final emailUrl = 'mailto:?subject=$encodedSubject&body=$encodedBody';
      
      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        LoggerService.info('Email app opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(
          ValidationException('Could not open email app'),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share to email', e, stackTrace);
      return Result.failure(
        ValidationException('Failed to open email app', originalError: e),
      );
    }
  }
}

