# 🎯 Quick Reference - AI Mood SaaS

## Configuration Checklist

### Step 1: Cloudflare AI Setup (5 min)
```
1. Go to https://dash.cloudflare.com/
2. Navigate to Workers & Pages → Cloudflare AI
3. Get Account ID from right sidebar
4. Create API Token: Account Settings → API Tokens → Create
5. Copy Account ID and Token
6. Update lib/config/cloudflare_config.dart:
   - accountId = 'YOUR_ACCOUNT_ID'
   - apiToken = 'YOUR_API_TOKEN'
```

### Step 2: Firebase Setup (10 min)
```
1. Go to https://console.firebase.google.com/
2. Create new project named "ai_mood"
3. Enable Email/Password Authentication
4. Create Firestore Database (test mode)
5. Go to Project Settings → General
6. Copy credentials:
   - API Key
   - Project ID
   - Auth Domain
7. Update lib/config/firebase_config.dart
```

### Step 3: Run Project
```bash
flutter pub get
flutter run
```

## Code Snippets

### Generate Message
```dart
import 'services/cloudflare_ai_service.dart';

// Generate single message
String msg = await CloudflareAIService.generateMessage(
  recipientType: 'crush',
  tone: 'romantic',
  context: 'ask her out for coffee',
  wordLimit: 100,
);

// Generate variations
List<String> msgs = await CloudflareAIService.generateMessageVariations(
  recipientType: 'girlfriend',
  tone: 'funny',
  context: 'apologize for being late',
  wordLimit: 80,
  count: 3,
);
```

### Auth Flow
```dart
import 'services/firebase_service.dart';

final service = FirebaseService();

// Sign up
await service.signUp(
  email: 'user@example.com',
  password: 'secure123',
  displayName: 'John Doe',
);

// Sign in
await service.signIn(
  email: 'user@example.com',
  password: 'secure123',
);

// Get current user
final user = await service.getCurrentUser();

// Sign out
await service.signOut();
```

### Save & Retrieve Messages
```dart
// Save message
await service.saveMessage(
  userId: user.uid,
  recipientType: 'crush',
  tone: 'romantic',
  content: generatedMessage,
  context: 'ask her out',
);

// Get all messages
List<GeneratedMessage> messages = await service.getUserMessages(user.uid);

// Rate message
await service.rateMessage(messageId, 5);

// Delete message
await service.deleteMessage(messageId);
```

### Subscription Management
```dart
// Upgrade subscription
await service.updateSubscription(
  userId: user.uid,
  planType: 'pro',
);

// Check usage
int creditsUsed = await service.getMonthlyCreditUsage(user.uid);

// Available plans
String free = AppConfig.subscriptionTiers['free']!.name;    // "Free"
String pro = AppConfig.subscriptionTiers['pro']!.name;      // "Pro"
String premium = AppConfig.subscriptionTiers['premium']!.name; // "Premium"
```

## Message Tones
```dart
AppConfig.availableTones = [
  'Romantic',     'Funny',        'Apologetic',   'Grateful',
  'Professional', 'Casual',       'Mysterious',   'Flirty',
  'Sincere',      'Playful',
];
```

## Recipient Categories
```dart
AppConfig.recipientCategories = [
  'Crush',             'Girlfriend/Boyfriend', 'Best Friend',   'Family',
  'Boss',              'Colleague',            'Parent',        'Sibling',
];
```

## Data Models

### User
```dart
User(
  uid: 'firebase_uid',
  email: 'user@example.com',
  displayName: 'John Doe',
  subscriptionTier: 'free',      // 'free', 'pro', 'premium'
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  monthlyCreditsUsed: 5,
  totalMessagesGenerated: 42,
)
```

### GeneratedMessage
```dart
GeneratedMessage(
  messageId: 'msg_123',
  userId: 'user_123',
  recipientType: 'crush',
  tone: 'romantic',
  content: 'Your beautiful message text...',
  context: 'express your feelings',
  createdAt: DateTime.now(),
  isSaved: true,
  rating: 5,
)
```

## Error Handling
```dart
try {
  String message = await CloudflareAIService.generateMessage(...);
} catch (e) {
  print('Error: $e');
  // Show error to user
}
```

## Common Errors & Fixes

| Error | Fix |
|-------|-----|
| `Target of URI doesn't exist` | Run `flutter pub get` |
| `The name 'User' is defined in...` | Use `firebase_auth as firebase_auth` (already done) |
| `401 Unauthorized from Cloudflare` | Check Account ID & API Token |
| `Permission denied` from Firebase | Update Firestore security rules |
| `pubspec.lock conflicts` | Run `flutter pub get --reset-with-sdk` |

## Firestore Collections Structure

```
users/{uid}/
  ├── email: string
  ├── displayName: string
  ├── subscriptionTier: string
  ├── createdAt: timestamp
  └── totalMessagesGenerated: number

messages/{messageId}/
  ├── userId: string (reference)
  ├── recipientType: string
  ├── tone: string
  ├── content: string
  ├── createdAt: timestamp
  ├── isSaved: boolean
  └── rating: number

subscriptions/{subscriptionId}/
  ├── userId: string
  ├── planType: string
  ├── startDate: timestamp
  ├── endDate: timestamp
  └── isActive: boolean

usage_logs/{logId}/
  ├── userId: string
  ├── creditsUsed: number
  └── date: timestamp
```

## Cloudflare AI Models
- `@cf/meta/llama-3-8b-instruct` (recommended)
- `@cf/meta/llama-2-7b-chat-int8`
- `@cf/mistral/mistral-7b-instruct-v0.1`

## Available Services

| Service | File | Methods |
|---------|------|---------|
| **CloudflareAIService** | `services/cloudflare_ai_service.dart` | generateMessage, generateMessageVariations |
| **FirebaseService** | `services/firebase_service.dart` | signUp, signIn, signOut, saveMessage, getUserMessages, updateSubscription, getMonthlyCreditUsage |

## File Locations
- Configs: `lib/config/`
- Services: `lib/services/`
- Models: `lib/models/`
- Screens: `lib/screens/` (create here)

## Dependencies
```yaml
http, firebase_core, firebase_auth, cloud_firestore,
riverpod, flutter_riverpod, hive, shared_preferences
```

---
📚 For more details, see:
- SETUP_GUIDE.md - Detailed setup
- API_DOCS.md - Full API documentation
- README.md - Project overview
