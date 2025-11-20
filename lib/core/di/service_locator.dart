import 'package:get_it/get_it.dart';
import '../services/connectivity_service.dart';
import '../../services/message_cache_service.dart';
import '../../services/message_management_service.dart';
import '../../services/firebase_service.dart';
import '../../services/firebase_ai_service.dart';
import '../../services/revenue_cat_service.dart';
import '../../services/subscription_service.dart';
import '../../services/message_scheduler_service.dart';
import '../../services/message_export_service.dart';
import '../../services/analytics_service.dart';
import '../network/dio_client.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupServiceLocator() async {
  // Core services - Enhanced features
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<MessageCacheService>(() => MessageCacheService());
  getIt.registerLazySingleton<MessageManagementService>(
    () => MessageManagementService(),
  );

  // Network
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Services - Singleton instances
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<FirebaseAIService>(() => FirebaseAIService());

  // Subscription & Payment services
  getIt.registerLazySingleton<RevenueCatService>(() => RevenueCatService());
  getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
  getIt.registerLazySingleton<MessageSchedulerService>(
    () => MessageSchedulerService(),
  );
  getIt.registerLazySingleton<MessageExportService>(
    () => MessageExportService(),
  );
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // Initialize services that need async setup
  try {
    // Initialize enhanced services first
    await getIt<ConnectivityService>().initialize();
    await getIt<MessageCacheService>().initialize();
    await getIt<MessageManagementService>().initialize();
    print('✅ Enhanced services initialized');

    // Initialize existing services
    await getIt<FirebaseAIService>().initialize();
    print('✅ Firebase AI Service initialized');
  } catch (e) {
    print('⚠️ Service initialization failed: $e');
  }

  // TODO: Add repositories when implemented
  // getIt.registerLazySingleton<UserRepository>(
  //   () => UserRepositoryImpl(getIt<FirebaseService>()),
  // );

  // TODO: Add use cases when implemented
  // getIt.registerFactory<GenerateMessageUseCase>(
  //   () => GenerateMessageUseCase(
  //     getIt<MessageRepository>(),
  //     getIt<AIRepository>(),
  //   ),
  // );
}

/// Reset service locator (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
