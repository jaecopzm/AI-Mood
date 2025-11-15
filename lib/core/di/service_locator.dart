import 'package:get_it/get_it.dart';
import '../../services/firebase_service.dart';
import '../../services/cloudflare_ai_service.dart';
import '../network/dio_client.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Setup dependency injection
Future<void> setupServiceLocator() async {
  // Network
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Services - Singleton instances
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<CloudflareAIService>(() => CloudflareAIService());

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
