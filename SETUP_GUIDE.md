# AI Mood - Environment Setup Guide

## Prerequisites

- Flutter SDK 3.10+
- Dart 3.10+
- Firebase Project
- Cloudflare Account

## 1. Firebase Setup

### Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "ai_mood"
3. Enable Authentication (Email/Password)
4. Create a Firestore Database
5. Set Firestore security rules to test mode for development

### Get Firebase Credentials

1. Go to Project Settings → Service Accounts
2. Copy your credentials
3. Create a `.env` file in the project root with:

```env
FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
FIREBASE_AUTH_DOMAIN=YOUR_PROJECT_ID.firebaseapp.com
FIREBASE_PROJECT_ID=YOUR_PROJECT_ID
FIREBASE_STORAGE_BUCKET=YOUR_PROJECT_ID.appspot.com
FIREBASE_MESSAGING_SENDER_ID=YOUR_MESSAGING_SENDER_ID
FIREBASE_APP_ID=YOUR_APP_ID
```

### Update lib/config/firebase_config.dart

Replace the placeholder values with your Firebase credentials:

```dart
static const String apiKey = 'YOUR_FIREBASE_API_KEY';
static const String authDomain = 'YOUR_PROJECT_ID.firebaseapp.com';
static const String projectId = 'YOUR_PROJECT_ID';
// ... etc
```

## 2. Cloudflare AI Setup

### Create Cloudflare Account

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Create an account if you don't have one
3. Go to Workers → Cloudflare AI

### Get API Token

1. Navigate to **Account Settings** → **API Tokens**
2. Create a new token with **Workers AI Read** permission
3. Copy the token

### Get Account ID

1. Go to Workers Overview
2. Copy your Account ID from the right sidebar

### Update lib/config/cloudflare_config.dart

```dart
static const String accountId = 'YOUR_CLOUDFLARE_ACCOUNT_ID';
static const String apiToken = 'YOUR_CLOUDFLARE_API_TOKEN';
```

### Testing Cloudflare AI (Optional)

Test your credentials with curl:

```bash
curl \
  https://api.cloudflare.com/client/v4/accounts/YOUR_ACCOUNT_ID/ai/run/@cf/meta/llama-3-8b-instruct \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{"messages":[{"role":"system","content":"You are a friendly assistant"},{"role":"user","content":"Hello"}]}'
```

## 3. Flutter Setup

### Install Dependencies

```bash
flutter pub get
```

### Generate Build Files

```bash
flutter pub run build_runner build
```

### Run the App

```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d web
```

## 4. Database Setup

### Create Firestore Collections

1. Go to Firebase Console → Firestore Database
2. Create these collections:
   - `users`
   - `messages`
   - `subscriptions`
   - `usage_logs`
   - `tones`
   - `recipients`

### Security Rules

Set up security rules to protect user data:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Messages belong to users
    match /messages/{messageId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
    
    // Public tone/recipient data
    match /tones/{document=**} {
      allow read: if request.auth != null;
    }
    
    match /recipients/{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```

## 5. SaaS Subscription Tiers

### Free Tier
- 5 messages/month
- Basic tones
- Ad-supported

### Pro Tier ($4.99/month)
- 100 messages/month
- All tones
- No ads
- Message history

### Premium Tier ($9.99/month)
- Unlimited messages
- All tones
- Priority support
- Custom tone creation
- Export messages

## 6. Environment Variables (Optional)

Create a `.env` file for local development:

```env
# Firebase
FIREBASE_API_KEY=your_key
FIREBASE_PROJECT_ID=your_project

# Cloudflare
CLOUDFLARE_ACCOUNT_ID=your_account_id
CLOUDFLARE_API_TOKEN=your_token

# App
APP_ENV=development
```

## Next Steps

1. ✅ Configure Firebase credentials
2. ✅ Configure Cloudflare API credentials
3. ✅ Create Firestore collections
4. ✅ Set up security rules
5. ✅ Run `flutter pub get`
6. ✅ Run the app: `flutter run`

## Troubleshooting

### "FirebaseAuth not found" error
- Ensure Firebase packages are added to pubspec.yaml
- Run `flutter pub get`
- Run `flutter pub run build_runner build`

### "Cloudflare API 401" error
- Verify your Account ID and API Token in cloudflare_config.dart
- Check that API token has Worker AI Read permission
- Test credentials with curl command above

### "Firestore permission denied" error
- Update security rules in Firebase Console
- Ensure your user is authenticated
- Check collection names match exactly
