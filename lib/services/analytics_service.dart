import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/logger_service.dart';

/// Analytics service for tracking user events
class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Track event
  Future<void> trackEvent({
    required String eventName,
    required String userId,
    Map<String, dynamic>? properties,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'eventName': eventName,
        'userId': userId,
        'properties': properties ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
      });

      LoggerService.info('📊 Event tracked: $eventName');
    } catch (e) {
      LoggerService.error('Failed to track event', e);
    }
  }

  // Onboarding Events
  Future<void> trackOnboardingStarted(String userId) async {
    await trackEvent(eventName: 'onboarding_started', userId: userId);
  }

  Future<void> trackOnboardingCompleted(
    String userId, {
    required List<String> selectedRecipients,
    required List<String> selectedTones,
  }) async {
    await trackEvent(
      eventName: 'onboarding_completed',
      userId: userId,
      properties: {
        'recipients_count': selectedRecipients.length,
        'tones_count': selectedTones.length,
        'recipients': selectedRecipients,
        'tones': selectedTones,
      },
    );
  }

  Future<void> trackOnboardingSkipped(String userId, int pageNumber) async {
    await trackEvent(
      eventName: 'onboarding_skipped',
      userId: userId,
      properties: {'page_number': pageNumber},
    );
  }

  // Authentication Events
  Future<void> trackSignUp(String userId, String method) async {
    await trackEvent(
      eventName: 'sign_up',
      userId: userId,
      properties: {'method': method}, // 'email' or 'google'
    );
  }

  Future<void> trackSignIn(String userId, String method) async {
    await trackEvent(
      eventName: 'sign_in',
      userId: userId,
      properties: {'method': method},
    );
  }

  // Message Events
  Future<void> trackMessageGenerated(
    String userId, {
    required String recipientType,
    required String tone,
    required int wordCount,
    bool usedTemplate = false,
    bool usedVoice = false,
  }) async {
    await trackEvent(
      eventName: 'message_generated',
      userId: userId,
      properties: {
        'recipient_type': recipientType,
        'tone': tone,
        'word_count': wordCount,
        'used_template': usedTemplate,
        'used_voice': usedVoice,
      },
    );
  }

  Future<void> trackMessageSaved(String userId, String messageId) async {
    await trackEvent(
      eventName: 'message_saved',
      userId: userId,
      properties: {'message_id': messageId},
    );
  }

  Future<void> trackMessageShared(
    String userId, {
    required String platform,
    required String messageId,
  }) async {
    await trackEvent(
      eventName: 'message_shared',
      userId: userId,
      properties: {'platform': platform, 'message_id': messageId},
    );
  }

  Future<void> trackMessageExported(
    String userId, {
    required String platform,
    required String messageId,
  }) async {
    await trackEvent(
      eventName: 'message_exported',
      userId: userId,
      properties: {'platform': platform, 'message_id': messageId},
    );
  }

  // Subscription Events
  Future<void> trackPaywallShown(
    String userId, {
    required String trigger,
    String? highlightedTier,
  }) async {
    await trackEvent(
      eventName: 'paywall_shown',
      userId: userId,
      properties: {
        'trigger': trigger, // 'limit_reached', 'premium_feature', 'manual'
        'highlighted_tier': highlightedTier,
      },
    );
  }

  Future<void> trackSubscriptionStarted(
    String userId, {
    required String tier,
    required bool isAnnual,
    required double price,
  }) async {
    await trackEvent(
      eventName: 'subscription_started',
      userId: userId,
      properties: {'tier': tier, 'is_annual': isAnnual, 'price': price},
    );
  }

  Future<void> trackSubscriptionUpgraded(
    String userId, {
    required String fromTier,
    required String toTier,
  }) async {
    await trackEvent(
      eventName: 'subscription_upgraded',
      userId: userId,
      properties: {'from_tier': fromTier, 'to_tier': toTier},
    );
  }

  Future<void> trackSubscriptionCancelled(
    String userId, {
    required String tier,
    required String reason,
  }) async {
    await trackEvent(
      eventName: 'subscription_cancelled',
      userId: userId,
      properties: {'tier': tier, 'reason': reason},
    );
  }

  // Feature Usage Events
  Future<void> trackTemplateUsed(
    String userId, {
    required String templateId,
    required bool isPremium,
  }) async {
    await trackEvent(
      eventName: 'template_used',
      userId: userId,
      properties: {'template_id': templateId, 'is_premium': isPremium},
    );
  }

  Future<void> trackVoiceInputUsed(String userId) async {
    await trackEvent(eventName: 'voice_input_used', userId: userId);
  }

  Future<void> trackVoiceOutputUsed(String userId) async {
    await trackEvent(eventName: 'voice_output_used', userId: userId);
  }

  Future<void> trackMessageScheduled(
    String userId, {
    required String platform,
    required DateTime scheduledFor,
  }) async {
    await trackEvent(
      eventName: 'message_scheduled',
      userId: userId,
      properties: {
        'platform': platform,
        'scheduled_for': scheduledFor.toIso8601String(),
        'hours_ahead': scheduledFor.difference(DateTime.now()).inHours,
      },
    );
  }

  // Limit Events
  Future<void> trackLimitReached(
    String userId, {
    required String tier,
    required int messagesUsed,
  }) async {
    await trackEvent(
      eventName: 'limit_reached',
      userId: userId,
      properties: {'tier': tier, 'messages_used': messagesUsed},
    );
  }

  Future<void> trackLimitWarning(
    String userId, {
    required String tier,
    required int messagesRemaining,
  }) async {
    await trackEvent(
      eventName: 'limit_warning',
      userId: userId,
      properties: {'tier': tier, 'messages_remaining': messagesRemaining},
    );
  }

  // Engagement Events
  Future<void> trackScreenView(String userId, String screenName) async {
    await trackEvent(
      eventName: 'screen_view',
      userId: userId,
      properties: {'screen_name': screenName},
    );
  }

  Future<void> trackFeatureDiscovered(String userId, String featureName) async {
    await trackEvent(
      eventName: 'feature_discovered',
      userId: userId,
      properties: {'feature_name': featureName},
    );
  }

  // Error Events
  Future<void> trackError(
    String userId, {
    required String errorType,
    required String errorMessage,
    String? screen,
  }) async {
    await trackEvent(
      eventName: 'error_occurred',
      userId: userId,
      properties: {
        'error_type': errorType,
        'error_message': errorMessage,
        'screen': screen,
      },
    );
  }

  // Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('analytics_events')
          .where('userId', isEqualTo: userId)
          .get();

      final events = snapshot.docs;
      final eventCounts = <String, int>{};

      for (var doc in events) {
        final eventName = doc.data()['eventName'] as String;
        eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
      }

      return {
        'total_events': events.length,
        'event_counts': eventCounts,
        'last_activity': events.isNotEmpty
            ? events.last.data()['timestamp']
            : null,
      };
    } catch (e) {
      LoggerService.error('Failed to get analytics summary', e);
      return {};
    }
  }
}
