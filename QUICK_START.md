# 🚀 Quick Start Guide - RevenueCat Integration

## ✅ What's Been Implemented

All the code is ready! Here's what you have:

### 1. **Models** ✅
- `subscription_model.dart` - Subscription tiers and plans
- `usage_tracking_model.dart` - Usage limits and tracking
- `template_model.dart` - Premium templates
- `scheduled_message_model.dart` - Message scheduling

### 2. **Services** ✅
- `revenue_cat_service.dart` - RevenueCat integration
- `subscription_service.dart` - Subscription management
- `message_scheduler_service.dart` - Scheduling
- `message_export_service.dart` - Multi-platform export

### 3. **Providers** ✅
- `subscription_provider.dart` - State management for subscriptions

### 4. **Configuration** ✅
- `revenue_cat_config.dart` - API keys and product IDs

---

## 🎯 Your To-Do List

### Step 1: Get RevenueCat API Key (5 min)
```
1. Go to: https://app.revenuecat.com/signup
2. Create account
3. Create project: "AI Mood"
4. Copy Android API Key from Settings → API Keys
```

### Step 2: Update Config (1 min)
```dart
// lib/config/revenue_cat_config.dart
static const String androidApiKey = 'PASTE_YOUR_KEY_HERE';
```

### Step 3: Install Dependencies (2 min)
```bash
flutter pub get
```

### Step 4: Set Up Google Play Console (30 min)
Follow detailed guide in: `REVENUECAT_SETUP.md`

**Quick version:**
1. Create Google Play Developer account ($25)
2. Create app
3. Create 4 subscription products:
   - `pro_monthly` - $4.99/month
   - `pro_annual` - $47.99/year
   - `premium_monthly` - $9.99/month
   - `premium_annual` - $95.99/year

### Step 5: Connect Google Play to RevenueCat (15 min)
1. Create service account in Google Cloud
2. Grant permissions in Google Play Console
3. Upload JSON to RevenueCat

### Step 6: Configure Entitlements (10 min)
In RevenueCat Dashboard:
1. Create "pro" entitlement → attach pro products
2. Create "premium" entitlement → attach premium products
3. Create "default" offering → add all packages

### Step 7: Test! (30 min)
```bash
flutter run
```
- Sign in
- Try purchasing (use test account)
- Verify subscription status updates

---

## 🎨 Next: Build the UI

Once RevenueCat is set up, you need to create:

### 1. Paywall Screen
```dart
// lib/screens/subscription/paywall_screen.dart
- Show subscription plans
- Display features comparison
- Purchase buttons
- Restore purchases button
```

### 2. Usage Indicator
```dart
// Add to home screen:
- "5/5 messages used"
- Progress bar
- "Upgrade" button when near limit
```

### 3. Premium Template Lock
```dart
// In template browser:
- Show 👑 badge on premium templates
- Blur locked templates
- "Unlock with Premium" button
```

### 4. Subscription Management
```dart
// In profile screen:
- Current plan display
- Usage statistics
- Manage subscription button
- Cancel/upgrade options
```

---

## 📝 Code Examples

### Check Subscription Status
```dart
final subscriptionState = ref.watch(subscriptionProvider);

if (subscriptionState.currentTier == SubscriptionTier.premium) {
  // User has premium
} else if (subscriptionState.currentTier == SubscriptionTier.pro) {
  // User has pro
} else {
  // User is on free tier
}
```

### Check if Can Generate Message
```dart
final canGenerate = await ref
    .read(subscriptionProvider.notifier)
    .canGenerateMessage(userId);

if (!canGenerate) {
  // Show paywall
  showPaywall(context);
} else {
  // Generate message
  generateMessage();
}
```

### Purchase Subscription
```dart
// Load offerings
await ref.read(subscriptionProvider.notifier).loadOfferings();

// Get package
final offerings = ref.read(subscriptionProvider).offerings;
final package = offerings?.current?.monthly;

// Purchase
final success = await ref
    .read(subscriptionProvider.notifier)
    .purchaseSubscription(package!, userId);

if (success) {
  // Show success message
} else {
  // Show error
}
```

### Restore Purchases
```dart
final success = await ref
    .read(subscriptionProvider.notifier)
    .restorePurchases(userId);
```

---

## 🧪 Testing Checklist

- [ ] App initializes RevenueCat successfully
- [ ] Offerings load correctly
- [ ] Can purchase Pro Monthly
- [ ] Can purchase Pro Annual
- [ ] Can purchase Premium Monthly
- [ ] Can purchase Premium Annual
- [ ] Subscription status updates after purchase
- [ ] Usage limits are enforced
- [ ] Can restore purchases
- [ ] Can cancel subscription
- [ ] Can upgrade from Pro to Premium
- [ ] Premium features unlock correctly

---

## 🐛 Common Issues & Fixes

### "RevenueCat not configured"
```dart
// Update lib/config/revenue_cat_config.dart with your API key
static const String androidApiKey = 'your_key_here';
```

### "No offerings available"
- Wait 24 hours after creating products in Google Play
- Check products are active
- Verify service account permissions

### "Purchase failed"
- Use test account added to license testing
- Check app signature matches Google Play
- Verify package name is correct

### "Entitlement not found"
- Check entitlement IDs in RevenueCat Dashboard
- Verify products are attached to entitlements
- Refresh offerings in app

---

## 📊 What You Get

### Free Tier
- 5 messages/month
- Basic tones (3)
- Basic recipients (3)
- 7-day history

### Pro Tier ($4.99/month)
- 100 messages/month
- All tones & recipients
- Voice features
- 30-day history
- No ads
- Basic analytics

### Premium Tier ($9.99/month)
- **Unlimited messages**
- Everything in Pro
- Premium templates
- Message scheduling
- Advanced analytics
- Unlimited history
- AI personalization

---

## 🎯 Success Metrics

Track these in RevenueCat Dashboard:
- **MRR** (Monthly Recurring Revenue)
- **Active Subscriptions**
- **Conversion Rate** (Free → Paid)
- **Churn Rate**
- **Trial Conversion**
- **ARPU** (Average Revenue Per User)

---

## 📞 Need Help?

1. **RevenueCat Docs**: https://docs.revenuecat.com/
2. **Community**: https://community.revenuecat.com/
3. **Support**: support@revenuecat.com

---

## 🚀 Launch Checklist

Before going live:
- [ ] RevenueCat API key configured
- [ ] Google Play products created and active
- [ ] Service account connected
- [ ] Entitlements configured
- [ ] Offerings set up
- [ ] Tested all purchase flows
- [ ] Paywall UI looks great
- [ ] Usage limits work correctly
- [ ] Analytics tracking enabled
- [ ] Privacy policy updated
- [ ] Terms of service updated

---

**Estimated Setup Time**: 1-2 hours
**Difficulty**: Medium
**Cost**: Free (RevenueCat free tier)

**You're ready to monetize! 💰**
