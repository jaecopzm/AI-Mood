# 🧪 Testing Guide - AI Mood Refactored Code

## Quick Start Testing

### 1. Verify Installation
```bash
# Check Flutter environment
flutter doctor

# Get all dependencies
flutter pub get

# Verify .env file exists
cat .env  # On Unix/Mac
type .env  # On Windows
```

### 2. Run the App
```bash
# Run in debug mode with verbose logging
flutter run --verbose

# Or run on specific device
flutter devices
flutter run -d <device-id>
```

---

## What to Test

### ✅ Phase 1: Initialization

**Expected Behavior:**
- App starts without errors
- Console shows initialization logs:
  ```
  💙 [INFO] Initializing environment configuration...
  💙 [INFO] Initializing Firebase...
  💙 [INFO] Initializing Hive...
  💙 [INFO] Setting up dependency injection...
  💙 [INFO] App initialization completed successfully
  ```

**Test Cases:**
1. **Normal startup**: App loads sign-in screen
2. **Missing .env**: Should show error screen with message
3. **Invalid Firebase config**: Should show error screen

**How to Test:**
```bash
# Normal startup
flutter run

# Test missing .env (rename it temporarily)
mv .env .env.backup
flutter run  # Should show error screen
mv .env.backup .env

# Check logs for proper initialization
flutter run 2>&1 | grep -E "INFO|ERROR|WARNING"
```

---

### ✅ Phase 2: Authentication

#### Test Case 1: Sign In with Validation

**Input Scenarios:**
| Input | Expected Result |
|-------|----------------|
| Empty email | "Email is required" |
| Invalid email format | "Please enter a valid email address" |
| Empty password | "Password is required" |
| Short password | "Password must be at least 6 characters" |
| Valid credentials | Signs in successfully |
| Wrong password | "Incorrect password. Please try again." |
| Non-existent user | "No user found with this email address." |

**How to Test:**
1. Open app → Sign In screen
2. Try each invalid input scenario above
3. Verify error messages appear
4. Check console logs:
   ```
   🔔 [INFO] Auth: Attempting sign in
   ⚠️ [ERROR] Auth: Sign in failed
   ```

#### Test Case 2: Sign Up with Validation

**Input Scenarios:**
| Input | Expected Result |
|-------|----------------|
| Empty email | "Email is required" |
| Invalid email | "Please enter a valid email address" |
| Weak password | "Password must contain at least one uppercase letter" |
| Empty name | "Name is required" |
| Short name | "Name must be at least 2 characters" |
| Special chars in name | "Name can only contain letters, spaces..." |
| Valid inputs | Signs up successfully |
| Existing email | "An account already exists with this email." |

**How to Test:**
1. Navigate to Sign Up screen
2. Test each validation scenario
3. Verify immediate feedback on invalid input
4. Check console for detailed logs

#### Test Case 3: Google Sign In

**Expected Flow:**
1. Click "Sign in with Google"
2. Google sign-in dialog appears
3. User selects account
4. App receives credentials
5. User document created/updated in Firestore
6. Navigates to home screen

**How to Test:**
```bash
# Ensure Google Sign In is configured
# Check android/app/google-services.json exists

flutter run

# Click Google Sign In button
# Follow prompts
# Check logs for success/failure
```

**Expected Logs:**
```
💙 [INFO] Auth: Attempting Google sign in
💙 [INFO] User document already exists for: [uid]
💙 [INFO] Auth: Google sign in successful
```

---

### ✅ Phase 3: Message Generation

#### Test Case 1: Generate Message

**Inputs to Test:**
1. Valid inputs → Success
2. Empty context → Validation error
3. Very long context → Validation error
4. Network timeout → User-friendly error
5. API error → Proper error message

**How to Test:**
1. Sign in successfully
2. Navigate to home/generate screen
3. Fill in message generation form:
   - Select recipient type
   - Select tone
   - Enter context
   - Click generate

**Expected Logs:**
```
💙 [INFO] Generating message for crush with romantic tone
💙 [INFO] Message generated successfully
💙 [INFO] Saving message: [id]
💙 [INFO] Message saved successfully
```

#### Test Case 2: Network Errors

**Simulate:**
1. Turn off WiFi/data
2. Try to generate message
3. Should see: "Network error. Please check your connection."

**Enable Airplane Mode:**
```bash
# On Android Emulator
adb shell svc wifi disable
adb shell svc data disable

# Try to generate
# Should see network error

# Re-enable
adb shell svc wifi enable
adb shell svc data enable
```

---

### ✅ Phase 4: Error Handling

#### Test Case 1: Firebase Errors

**Scenarios:**
| Scenario | How to Test | Expected Error |
|----------|-------------|----------------|
| Network down | Disable internet | "Network error. Please check your connection." |
| Rate limit | Make many requests | "Too many requests. Please try again later." |
| Invalid token | Manually corrupt token | "Unauthorized. Please log in again." |

#### Test Case 2: Validation Errors

**Test Script:**
```dart
// Test in Dart console or write a simple test
import 'package:ai_mood/core/validators/input_validators.dart';

void main() {
  // Email tests
  print(InputValidators.validateEmail('')); // "Email is required"
  print(InputValidators.validateEmail('invalid')); // "Please enter valid..."
  print(InputValidators.validateEmail('test@example.com')); // null (valid)
  
  // Password tests
  print(InputValidators.validatePassword('123')); // "Must be at least 8..."
  print(InputValidators.validatePassword('password')); // "Must contain uppercase"
  print(InputValidators.validatePassword('Password123')); // null (valid)
  
  // Name tests
  print(InputValidators.validateDisplayName('A')); // "Must be at least 2..."
  print(InputValidators.validateDisplayName('John Doe')); // null (valid)
  print(InputValidators.validateDisplayName('John123')); // "Can only contain..."
}
```

---

## 📊 Logging Verification

### What to Look For

**Good Signs:**
```
✅ 💙 [INFO] messages appear frequently
✅ 🔔 [DEBUG] messages for detailed flow
✅ ⚠️ [WARNING] for non-critical issues (recovered)
✅ ❌ [ERROR] with stack traces when needed
```

**Bad Signs:**
```
❌ No logs appearing (logger not working)
❌ Raw stack traces without context
❌ Generic "Exception" messages
❌ App crashes without error logs
```

### Enable Verbose Logging

```bash
# Run with verbose output
flutter run --verbose

# Filter for specific logs
flutter run 2>&1 | grep -E "Auth:|Message:|Network:"

# Save logs to file
flutter run > app_logs.txt 2>&1
```

---

## 🔍 Manual Testing Checklist

### Authentication Flow
- [ ] Sign in with valid credentials
- [ ] Sign in with invalid credentials
- [ ] Sign up with new account
- [ ] Sign up with existing email
- [ ] Google sign in
- [ ] Logout
- [ ] Email validation works
- [ ] Password validation works
- [ ] Name validation works

### Message Generation Flow
- [ ] Generate message with valid inputs
- [ ] Generate message with empty context
- [ ] Generate message with long context
- [ ] Generate multiple variations
- [ ] Save generated message
- [ ] View message history
- [ ] Delete message
- [ ] Update message (favorite/unfavorite)

### Error Scenarios
- [ ] Network error handling
- [ ] API timeout handling
- [ ] Invalid input handling
- [ ] Firebase error handling
- [ ] User-friendly error messages displayed
- [ ] No app crashes on errors

### Environment & Security
- [ ] API keys not visible in code
- [ ] Environment variables loaded correctly
- [ ] App works with .env file
- [ ] App shows error without .env file

---

## 🐛 Common Issues & Solutions

### Issue 1: App won't start
**Symptoms:** White screen or immediate crash

**Solutions:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check .env file exists
ls -la .env

# Verify Firebase configuration
cat android/app/google-services.json
```

### Issue 2: No logs appearing
**Symptoms:** Console is silent

**Solutions:**
```bash
# Run in verbose mode
flutter run --verbose

# Check log level in LoggerService
# Ensure it's set to Level.debug
```

### Issue 3: Environment variables not loading
**Symptoms:** Error about missing CLOUDFLARE_ACCOUNT_ID

**Solutions:**
```bash
# Verify .env file format
cat .env
# Should have:
# CLOUDFLARE_ACCOUNT_ID=your_id
# CLOUDFLARE_API_TOKEN=your_token

# Ensure .env is in project root
ls -la | grep .env

# Rebuild app
flutter clean
flutter pub get
flutter run
```

### Issue 4: Firebase errors
**Symptoms:** Authentication fails with Firebase errors

**Solutions:**
```bash
# Check Firebase setup
flutter pub get

# Verify google-services.json exists
ls android/app/google-services.json

# Re-download Firebase config if needed
# From Firebase Console
```

### Issue 5: Validation not working
**Symptoms:** Can submit invalid forms

**Solution:**
- Check provider is using updated AuthProvider
- Verify validators are being called
- Check error state is being displayed in UI

---

## 📝 Test Results Template

Use this to document your testing:

```markdown
## Test Session: [Date]

### Environment
- Device/Emulator: 
- OS Version:
- App Version:

### Tests Performed

#### Authentication
- [ ] Sign In: ✅/❌
  - Notes:
- [ ] Sign Up: ✅/❌
  - Notes:
- [ ] Google Sign In: ✅/❌
  - Notes:
- [ ] Validation: ✅/❌
  - Notes:

#### Message Generation
- [ ] Generate: ✅/❌
  - Notes:
- [ ] Save: ✅/❌
  - Notes:
- [ ] History: ✅/❌
  - Notes:

#### Error Handling
- [ ] Network errors: ✅/❌
- [ ] Validation errors: ✅/❌
- [ ] Firebase errors: ✅/❌

### Issues Found
1. [Issue description]
2. [Issue description]

### Logs
```
[Paste relevant logs here]
```

### Screenshots
[Attach if needed]
```

---

## 🚀 Automated Testing (Future)

When ready to write automated tests:

```dart
// Example unit test for validators
// test/validators/input_validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_mood/core/validators/input_validators.dart';

void main() {
  group('Email Validation', () {
    test('empty email returns error', () {
      expect(
        InputValidators.validateEmail(''),
        equals('Email is required'),
      );
    });
    
    test('invalid email returns error', () {
      expect(
        InputValidators.validateEmail('invalid'),
        contains('valid email'),
      );
    });
    
    test('valid email returns null', () {
      expect(
        InputValidators.validateEmail('test@example.com'),
        isNull,
      );
    });
  });
}
```

Run tests:
```bash
flutter test
flutter test --coverage
```

---

**Happy Testing! 🎉**
