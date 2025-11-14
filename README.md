# AI Mood - SaaS Message Generator App

> AI-powered personalized message writer for friends, family, crush, and significant others using Cloudflare AI & Firebase

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│         Flutter Mobile App (Frontend)       │
│  - Auth Screen                              │
│  - Message Generator Screen                 │
│  - Message History                          │
│  - Subscription Management                  │
└────────────────┬────────────────────────────┘
                 │ HTTP/REST API
         ┌───────▼────────────┐
         │  Cloud Services    │
         ├────────────────────┤
         │ Firebase Auth      │ (User Authentication)
         │ Firestore Database │ (Data Storage)
         │ Cloudflare AI      │ (LLM for Messages)
         └────────────────────┘
```

## Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # App settings, subscription tiers, tones, recipients
│   ├── cloudflare_config.dart   # Cloudflare AI API credentials
│   └── firebase_config.dart     # Firebase project configuration
├── models/
│   ├── cloudflare_request.dart  # AI request/response models
│   └── user_model.dart          # User, Subscription, Message models
├── services/
│   ├── cloudflare_ai_service.dart   # Message generation service
│   └── firebase_service.dart        # Auth & database service
├── screens/                     # UI screens (to be created)
└── main.dart                    # App entry point
```

## Key Features

### 1. **SaaS Subscription Model**
- **Free**: 5 messages/month
- **Pro**: 100 messages/month ($4.99/month)
- **Premium**: Unlimited ($9.99/month)

### 2. **Message Tones**
Romantic, Funny, Apologetic, Grateful, Professional, Casual, Mysterious, Flirty, Sincere, Playful

### 3. **Recipient Categories**
Crush, Girlfriend/Boyfriend, Best Friend, Family, Boss, Colleague, Parent, Sibling

### 4. **Core Services**

#### CloudflareAIService
Generate personalized messages using Cloudflare's LLM:
- `generateMessage()` - Create single message
- `generateMessageVariations()` - Create multiple versions

#### FirebaseService
Handle authentication & data management:
- `signUp()`, `signIn()`, `signOut()` - Auth methods
- `saveMessage()`, `getUserMessages()` - Message management
- `updateSubscription()` - Subscription handling
- `getMonthlyCreditUsage()` - Usage tracking

## Quick Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase
Update `lib/config/firebase_config.dart`:
```dart
static const String apiKey = 'YOUR_FIREBASE_API_KEY';
static const String projectId = 'YOUR_PROJECT_ID';
// ... add other credentials
```

### 3. Configure Cloudflare AI
Update `lib/config/cloudflare_config.dart`:
```dart
static const String accountId = 'YOUR_CLOUDFLARE_ACCOUNT_ID';
static const String apiToken = 'YOUR_CLOUDFLARE_API_TOKEN';
```

### 4. Run the App
```bash
flutter run
```

## Usage Examples

### Generate a Message
```dart
import 'package:ai_mood/services/cloudflare_ai_service.dart';

final message = await CloudflareAIService.generateMessage(
  recipientType: 'crush',
  tone: 'romantic',
  context: 'express your feelings naturally',
  wordLimit: 100,
  additionalContext: 'She loves poetry',
);
print(message);
```

### Save Message to Firestore
```dart
import 'package:ai_mood/services/firebase_service.dart';

final firebaseService = FirebaseService();

await firebaseService.saveMessage(
  userId: 'user123',
  recipientType: 'crush',
  tone: 'romantic',
  content: 'Generated message here...',
  context: 'express feelings',
);
```

### Authenticate User
```dart
await firebaseService.signUp(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
);

await firebaseService.signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.10+ |
| **State Management** | Riverpod |
| **Auth** | Firebase Authentication |
| **Database** | Firestore |
| **AI Engine** | Cloudflare Workers AI |
| **HTTP Client** | http package |
| **Storage** | Hive (local caching) |

## Firestore Data Schema

### users
```json
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "John Doe",
  "subscriptionTier": "free",
  "createdAt": "2025-11-14...",
  "monthlyCreditsUsed": 2,
  "totalMessagesGenerated": 15
}
```

### messages
```json
{
  "messageId": "msg_123",
  "userId": "user_123",
  "recipientType": "crush",
  "tone": "romantic",
  "content": "Your beautiful message...",
  "context": "express feelings",
  "createdAt": "2025-11-14...",
  "isSaved": true,
  "rating": 5
}
```

## Cloudflare AI Integration

**Endpoint**: `https://api.cloudflare.com/client/v4/accounts/{accountId}/ai/run/@cf/meta/llama-3-8b-instruct`

**Available Models**:
- `@cf/meta/llama-3-8b-instruct` (recommended)
- `@cf/meta/llama-2-7b-chat-int8`
- `@cf/mistral/mistral-7b-instruct-v0.1`

**Request Format**:
```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a message writing expert..."
    },
    {
      "role": "user",
      "content": "Write a romantic message for my crush"
    }
  ]
}
```

## Development Roadmap

- [ ] Create Home/Generator screen
- [ ] Create Authentication screens
- [ ] Create Message History screen
- [ ] Create Subscription management
- [ ] Implement Stripe payments
- [ ] Add message sharing functionality
- [ ] Add favorites/saved messages
- [ ] Analytics dashboard
- [ ] Admin panel for content moderation

## Environment Files

### .env (Development)
```env
FIREBASE_API_KEY=xxx
CLOUDFLARE_ACCOUNT_ID=xxx
CLOUDFLARE_API_TOKEN=xxx
APP_ENV=development
```

## API Documentation

See `API_DOCS.md` for detailed service methods and data models.

## Setup Guide

See `SETUP_GUIDE.md` for step-by-step setup instructions.

## Error Handling

All services throw descriptive exceptions:
```dart
try {
  await cloudflareService.generateMessage(...);
} catch (e) {
  print('Error: $e');
  // Handle error
}
```

## Common Issues

| Issue | Solution |
|-------|----------|
| FirebaseAuth import conflict | Already fixed using `firebase_auth as` alias |
| Missing dependencies | Run `flutter pub get` |
| Cloudflare 401 error | Verify Account ID and API Token |
| Firestore permission denied | Update security rules |

## Dependencies

- `http: ^1.1.0` - API calls
- `firebase_core: ^2.24.0` - Firebase base
- `firebase_auth: ^4.15.0` - Authentication
- `cloud_firestore: ^4.14.0` - Database
- `flutter_riverpod: ^2.4.0` - State management
- `shared_preferences: ^2.2.2` - Local storage
- `hive: ^2.2.3` - Local data caching

## License

MIT

## Support

For issues or questions, check the SETUP_GUIDE.md and API_DOCS.md files.
