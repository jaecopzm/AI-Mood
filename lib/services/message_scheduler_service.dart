import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/scheduled_message_model.dart';
import '../core/services/logger_service.dart';
import '../core/utils/result.dart';

/// Service for scheduling messages
class MessageSchedulerService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  MessageSchedulerService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Schedule a message
  Future<Result<ScheduledMessage>> scheduleMessage({
    required String userId,
    required String messageText,
    required String recipientType,
    required String tone,
    required DateTime scheduledFor,
    String? platform,
    String? recipientContact,
  }) async {
    try {
      // Validate scheduled time is in the future
      if (scheduledFor.isBefore(DateTime.now())) {
        return Result.failure(
          Exception('Scheduled time must be in the future'),
        );
      }

      final scheduledMessage = ScheduledMessage(
        id: _uuid.v4(),
        userId: userId,
        messageText: messageText,
        recipientType: recipientType,
        tone: tone,
        scheduledFor: scheduledFor,
        platform: platform,
        recipientContact: recipientContact,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('scheduled_messages')
          .doc(scheduledMessage.id)
          .set(scheduledMessage.toJson());

      LoggerService.info('Message scheduled: ${scheduledMessage.id}');
      return Result.success(scheduledMessage);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to schedule message', e, stackTrace);
      return Result.failure(Exception('Failed to schedule message: $e'));
    }
  }

  /// Get all scheduled messages for a user
  Future<Result<List<ScheduledMessage>>> getScheduledMessages(
    String userId, {
    bool includeCompleted = false,
  }) async {
    try {
      Query query = _firestore
          .collection('scheduled_messages')
          .where('userId', isEqualTo: userId);

      if (!includeCompleted) {
        query = query
            .where('isCompleted', isEqualTo: false)
            .where('isCancelled', isEqualTo: false);
      }

      final snapshot = await query.orderBy('scheduledFor').get();

      final messages = snapshot.docs
          .map(
            (doc) =>
                ScheduledMessage.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      return Result.success(messages);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get scheduled messages', e, stackTrace);
      return Result.failure(Exception('Failed to get scheduled messages: $e'));
    }
  }

  /// Get upcoming scheduled messages (next 7 days)
  Future<Result<List<ScheduledMessage>>> getUpcomingMessages(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('scheduled_messages')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .where('isCancelled', isEqualTo: false)
          .where(
            'scheduledFor',
            isGreaterThanOrEqualTo: Timestamp.fromDate(now),
          )
          .where(
            'scheduledFor',
            isLessThanOrEqualTo: Timestamp.fromDate(nextWeek),
          )
          .orderBy('scheduledFor')
          .get();

      final messages = snapshot.docs
          .map((doc) => ScheduledMessage.fromJson(doc.data()))
          .toList();

      return Result.success(messages);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get upcoming messages', e, stackTrace);
      return Result.failure(Exception('Failed to get upcoming messages: $e'));
    }
  }

  /// Cancel a scheduled message
  Future<Result<void>> cancelScheduledMessage(String messageId) async {
    try {
      await _firestore.collection('scheduled_messages').doc(messageId).update({
        'isCancelled': true,
      });

      LoggerService.info('Scheduled message cancelled: $messageId');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to cancel scheduled message', e, stackTrace);
      return Result.failure(
        Exception('Failed to cancel scheduled message: $e'),
      );
    }
  }

  /// Mark message as completed
  Future<Result<void>> markAsCompleted(String messageId) async {
    try {
      await _firestore.collection('scheduled_messages').doc(messageId).update({
        'isCompleted': true,
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });

      LoggerService.info('Scheduled message marked as completed: $messageId');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to mark message as completed', e, stackTrace);
      return Result.failure(
        Exception('Failed to mark message as completed: $e'),
      );
    }
  }

  /// Reschedule a message
  Future<Result<void>> rescheduleMessage(
    String messageId,
    DateTime newScheduledTime,
  ) async {
    try {
      if (newScheduledTime.isBefore(DateTime.now())) {
        return Result.failure(
          Exception('Scheduled time must be in the future'),
        );
      }

      await _firestore.collection('scheduled_messages').doc(messageId).update({
        'scheduledFor': Timestamp.fromDate(newScheduledTime),
      });

      LoggerService.info('Message rescheduled: $messageId');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to reschedule message', e, stackTrace);
      return Result.failure(Exception('Failed to reschedule message: $e'));
    }
  }

  /// Delete a scheduled message
  Future<Result<void>> deleteScheduledMessage(String messageId) async {
    try {
      await _firestore.collection('scheduled_messages').doc(messageId).delete();

      LoggerService.info('Scheduled message deleted: $messageId');
      return Result.success(null);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete scheduled message', e, stackTrace);
      return Result.failure(
        Exception('Failed to delete scheduled message: $e'),
      );
    }
  }

  /// Get count of scheduled messages
  Future<int> getScheduledMessageCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('scheduled_messages')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .where('isCancelled', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      LoggerService.error('Failed to get scheduled message count', e);
      return 0;
    }
  }
}
