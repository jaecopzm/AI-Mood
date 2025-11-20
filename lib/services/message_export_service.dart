import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

/// Service for exporting messages to different platforms
class MessageExportService {
  /// Export to WhatsApp
  Future<Result<void>> exportToWhatsApp(
    String message, {
    String? phoneNumber,
  }) async {
    try {
      LoggerService.info('Exporting to WhatsApp');

      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = phoneNumber != null
          ? 'https://wa.me/$phoneNumber?text=$encodedMessage'
          : 'https://wa.me/?text=$encodedMessage';

      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        LoggerService.info('WhatsApp opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(Exception('WhatsApp is not installed'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to export to WhatsApp', e, stackTrace);
      return Result.failure(Exception('Failed to open WhatsApp: $e'));
    }
  }

  /// Export to SMS
  Future<Result<void>> exportToSMS(
    String message, {
    String? phoneNumber,
  }) async {
    try {
      LoggerService.info('Exporting to SMS');

      final encodedMessage = Uri.encodeComponent(message);
      final smsUrl = phoneNumber != null
          ? 'sms:$phoneNumber?body=$encodedMessage'
          : 'sms:?body=$encodedMessage';

      final uri = Uri.parse(smsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        LoggerService.info('SMS app opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(Exception('Could not open SMS app'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to export to SMS', e, stackTrace);
      return Result.failure(Exception('Failed to open SMS app: $e'));
    }
  }

  /// Export to Email
  Future<Result<void>> exportToEmail(
    String message, {
    String? email,
    String? subject,
  }) async {
    try {
      LoggerService.info('Exporting to Email');

      final encodedSubject = Uri.encodeComponent(
        subject ?? 'Message from AI Mood',
      );
      final encodedBody = Uri.encodeComponent(message);
      final emailUrl = email != null
          ? 'mailto:$email?subject=$encodedSubject&body=$encodedBody'
          : 'mailto:?subject=$encodedSubject&body=$encodedBody';

      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        LoggerService.info('Email app opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(Exception('Could not open email app'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to export to email', e, stackTrace);
      return Result.failure(Exception('Failed to open email app: $e'));
    }
  }

  /// Export to Twitter
  Future<Result<void>> exportToTwitter(String message) async {
    try {
      LoggerService.info('Exporting to Twitter');

      final encodedMessage = Uri.encodeComponent(
        '$message\n\n#AIMood #AIGenerated',
      );
      final twitterUrl =
          'https://twitter.com/intent/tweet?text=$encodedMessage';

      final uri = Uri.parse(twitterUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        LoggerService.info('Twitter opened successfully');
        return Result.success(null);
      } else {
        return Result.failure(Exception('Could not open Twitter'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to export to Twitter', e, stackTrace);
      return Result.failure(Exception('Failed to open Twitter: $e'));
    }
  }

  /// Export to Instagram (via share sheet)
  Future<Result<void>> exportToInstagram(String message) async {
    try {
      LoggerService.info('Exporting to Instagram');

      // Instagram doesn't support direct text sharing via URL
      // Use the share sheet instead
      await Share.share(message, subject: 'Message from AI Mood');

      LoggerService.info('Share sheet opened for Instagram');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to export to Instagram', e, stackTrace);
      return Result.failure(Exception('Failed to share to Instagram: $e'));
    }
  }

  /// Generic share (opens system share sheet)
  Future<Result<void>> shareMessage(String message, {String? subject}) async {
    try {
      LoggerService.info('Opening share sheet');

      await Share.share(message, subject: subject ?? 'Message from AI Mood');

      LoggerService.info('Share sheet opened successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share message', e, stackTrace);
      return Result.failure(Exception('Failed to share message: $e'));
    }
  }

  /// Share with watermark for free users
  Future<Result<void>> shareWithWatermark(
    String message,
    bool isPremiumUser,
  ) async {
    try {
      final messageToShare = isPremiumUser
          ? message
          : '$message\n\n✨ Generated with AI Mood\n💝 Get yours at aimood.app';

      return await shareMessage(messageToShare);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to share with watermark', e, stackTrace);
      return Result.failure(Exception('Failed to share: $e'));
    }
  }

  /// Export options available
  List<ExportOption> getAvailableExportOptions() {
    return [
      ExportOption(
        name: 'WhatsApp',
        icon: '💬',
        description: 'Share via WhatsApp',
        platform: ExportPlatform.whatsapp,
      ),
      ExportOption(
        name: 'SMS',
        icon: '📱',
        description: 'Send as text message',
        platform: ExportPlatform.sms,
      ),
      ExportOption(
        name: 'Email',
        icon: '📧',
        description: 'Send via email',
        platform: ExportPlatform.email,
      ),
      ExportOption(
        name: 'Twitter',
        icon: '🐦',
        description: 'Share on Twitter',
        platform: ExportPlatform.twitter,
      ),
      ExportOption(
        name: 'More',
        icon: '📤',
        description: 'More sharing options',
        platform: ExportPlatform.generic,
      ),
    ];
  }
}

/// Export platform enum
enum ExportPlatform { whatsapp, sms, email, twitter, instagram, generic }

/// Export option model
class ExportOption {
  final String name;
  final String icon;
  final String description;
  final ExportPlatform platform;

  const ExportOption({
    required this.name,
    required this.icon,
    required this.description,
    required this.platform,
  });
}
