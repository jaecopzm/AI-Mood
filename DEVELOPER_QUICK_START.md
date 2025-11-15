# 🚀 Developer Quick Start Guide

## 30-Second Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Verify .env file exists
cat .env

# 3. Run the app
flutter run
```

---

## Essential Patterns to Use

### 1. Input Validation (Always!)
```dart
import 'package:ai_mood/core/validators/input_validators.dart';

// Email
final error = InputValidators.validateEmail(email);
if (error != null) {
  showError(error);
  return;
}

// Password
final error = InputValidators.validatePassword(password);

// Custom
final error = InputValidators.validateRequired(value, 'Field Name');
```

### 2. Error Handling with Result
```dart
import 'package:ai_mood/core/utils/result.dart';
import 'package:ai_mood/core/services/error_handler.dart';

final result = await service.someOperation();

result.when(
  success: (data) {
    // Handle success
  },
  failure: (error) {
    final message = ErrorHandler.getUserFriendlyMessage(error);
    showSnackBar(message);
  },
);
```

### 3. Logging
```dart
import 'package:ai_mood/core/services/logger_service.dart';

LoggerService.info('User signed in');
LoggerService.debug('Processing data: $data');
LoggerService.warning('Something unusual', error);
LoggerService.error('Operation failed', error, stackTrace);
```

### 4. Custom Exceptions
```dart
import 'package:ai_mood/core/exceptions/app_exceptions.dart';

throw ValidationException('Invalid input', fieldErrors: {
  'email': 'Invalid email format',
});

throw NetworkException('Connection failed');
throw AuthException('Authentication failed');
```

### 5. Dependency Injection
```dart
import 'package:ai_mood/core/di/service_locator.dart';

// In service_locator.dart
getIt.registerLazySingleton<MyService>(() => MyService());

// In providers
final myService = getIt<MyService>();
```

---

## Common Tasks

### Add a New Service

```dart
// 1. Create service
class MyService {
  Future<Result<Data>> fetchData() async {
    try {
      LoggerService.info('Fetching data');
      // ... fetch logic
      return Result.success(data);
    } on DioException catch (e) {
      return Result.failure(ErrorHandler.convertDioException(e));
    } catch (e, stackTrace) {
      LoggerService.error('Fetch failed', e, stackTrace);
      return Result.failure(AppException('Failed to fetch data'));
    }
  }
}

// 2. Register in service_locator.dart
getIt.registerLazySingleton<MyService>(() => MyService());

// 3. Use in provider
final myServiceProvider = Provider<MyService>((ref) {
  return getIt<MyService>();
});
```

### Add a New Validator

```dart
// In lib/core/validators/input_validators.dart

static String? validateCustomField(String? value) {
  if (value == null || value.isEmpty) {
    return 'Field is required';
  }
  
  if (value.length < 5) {
    return 'Must be at least 5 characters';
  }
  
  // Custom logic
  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
    return 'Only letters allowed';
  }
  
  return null; // Valid
}
```

### Handle a New Error Type

```dart
// 1. Add exception type (if needed)
// In lib/core/exceptions/app_exceptions.dart
class PaymentException extends AppException {
  PaymentException(String message) : super(message, code: 'PAYMENT_ERROR');
}

// 2. Add to ErrorHandler
// In lib/core/services/error_handler.dart
if (error is PaymentException) {
  return 'Payment failed. Please try again.';
}
```

---

## File Structure

```
lib/
├── core/                          # Core infrastructure
│   ├── config/
│   │   └── env_config.dart       # Environment variables
│   ├── di/
│   │   └── service_locator.dart  # Dependency injection
│   ├── exceptions/
│   │   └── app_exceptions.dart   # Custom exceptions
│   ├── network/
│   │   └── dio_client.dart       # HTTP client wrapper
│   ├── services/
│   │   ├── error_handler.dart    # Error handling utilities
│   │   └── logger_service.dart   # Logging service
│   ├── utils/
│   │   └── result.dart           # Result type
│   └── validators/
│       └── input_validators.dart # Input validation
│
├── config/                        # App configuration
│   ├── cloudflare_config.dart    # Cloudflare settings
│   ├── firebase_config.dart      # Firebase settings
│   └── premium_theme.dart        # Theme configuration
│
├── models/                        # Data models
│   ├── user_model.dart
│   ├── message_model.dart
│   └── cloudflare_request.dart
│
├── services/                      # Business logic
│   ├── firebase_service.dart
│   └── cloudflare_ai_service.dart
│
├── providers/                     # State management
│   ├── auth_provider.dart
│   └── message_provider.dart
│
├── screens/                       # UI screens
│   ├── auth/
│   ├── home/
│   ├── history/
│   └── profile/
│
└── main.dart                      # App entry point
```

---

## Cheat Sheet

### Environment Variables
```bash
# .env file
CLOUDFLARE_ACCOUNT_ID=your_id
CLOUDFLARE_API_TOKEN=your_token
ENVIRONMENT=development
```

### Result Type Methods
```dart
result.isSuccess        // bool
result.isFailure        // bool
result.data            // T? (nullable)
result.error           // dynamic
result.dataOrThrow     // T (throws if failure)
result.getOrElse(def)  // T (returns default if failure)
result.map(fn)         // Transform success value
result.when(...)       // Handle both cases
```

### Validator Methods
```dart
InputValidators.validateEmail(email)
InputValidators.validatePassword(password)
InputValidators.validateDisplayName(name)
InputValidators.validateMessageContext(context)
InputValidators.validateRequired(value, fieldName)
InputValidators.validateMinLength(value, min, fieldName)
InputValidators.validateMaxLength(value, max, fieldName)
InputValidators.sanitizeInput(input)
```

### Logger Methods
```dart
LoggerService.debug(msg, [error, stackTrace])
LoggerService.info(msg)
LoggerService.warning(msg, [error, stackTrace])
LoggerService.error(msg, [error, stackTrace])
LoggerService.fatal(msg, [error, stackTrace])
```

---

## Testing Tips

### Manual Testing
```bash
# Run with logs
flutter run --verbose

# Filter logs
flutter run 2>&1 | grep "INFO"

# Test specific device
flutter devices
flutter run -d chrome
```

### Check Logs
Look for these patterns:
```
💙 [INFO]  - Normal operation
🔔 [DEBUG] - Detailed debug info
⚠️ [WARNING] - Non-critical issues
❌ [ERROR] - Errors with context
```

### Common Test Scenarios
1. **Sign in with wrong password** → Should show friendly error
2. **Generate message with empty context** → Should show validation error
3. **Turn off internet, try to sign in** → Should show network error
4. **Submit form with invalid email** → Should show validation error

---

## Troubleshooting

### App won't start
```bash
flutter clean
flutter pub get
flutter run
```

### Environment variables not loading
```bash
# Check .env exists
ls -la .env

# Check format (no quotes, no spaces around =)
cat .env
```

### No logs showing
```bash
# Run in verbose mode
flutter run --verbose

# Check LoggerService level is set to debug
```

### Firebase errors
```bash
# Verify Firebase files exist
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist

# Re-download from Firebase Console if needed
```

---

## Best Practices Summary

✅ **Always validate input** before API calls  
✅ **Use Result type** instead of throwing exceptions  
✅ **Log important operations** for debugging  
✅ **Handle errors gracefully** with user-friendly messages  
✅ **Use dependency injection** for testability  
✅ **Never hardcode credentials** - use .env  
✅ **Write null-safe code** - check before accessing  
✅ **Sanitize user input** to prevent injection  
✅ **Use custom exceptions** for specific errors  
✅ **Document complex logic** with comments  

---

## Quick Reference: Before & After

### Error Handling
```dart
// ❌ OLD - Don't use
try {
  final data = await service.fetch();
  useData(data);
} catch (e) {
  print('Error: $e'); // Generic
}

// ✅ NEW - Use this
final result = await service.fetch();
result.when(
  success: (data) => useData(data),
  failure: (error) {
    final msg = ErrorHandler.getUserFriendlyMessage(error);
    showError(msg);
  },
);
```

### Input Validation
```dart
// ❌ OLD - Don't use
if (email.isEmpty) {
  showError('Email required');
  return;
}

// ✅ NEW - Use this
final error = InputValidators.validateEmail(email);
if (error != null) {
  showError(error);
  return;
}
```

### Service Calls
```dart
// ❌ OLD - Don't use
final result = await CloudflareAIService.generateMessage(...);

// ✅ NEW - Use this
final service = getIt<CloudflareAIService>();
final result = await service.generateMessage(...);
```

---

## Resources

- **CODE_QUALITY_ANALYSIS.md** - Detailed technical documentation
- **REFACTORING_PROGRESS.md** - Implementation progress
- **TESTING_GUIDE.md** - Testing procedures
- **REFACTORING_COMPLETE_SUMMARY.md** - Executive summary

---

## Getting Help

1. **Check logs first** - They're comprehensive now
2. **Review TESTING_GUIDE.md** - Common issues covered
3. **Verify .env configuration** - Most issues are here
4. **Run flutter doctor** - Check environment setup

---

**You're all set! Happy coding! 🚀**
