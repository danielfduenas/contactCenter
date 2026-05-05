# 📖 Quick Start - 15 Minutes to Working System

## Choose Your Path

### 👨‍💻 Developer (Build & Test)
Go to: **[BUILD_GUIDE.md](#build-guide-30-minutes)** below

### 🧑‍💼 Manager (Understand Status)  
Read: **[PROJECT_STATUS.md](PROJECT_STATUS.md)** (5 minutes)

### 🔧 Architect (Deep Dive)
Read: **[ARCHITECTURE.md](ARCHITECTURE.md)** (15 minutes)

---

## Build Guide (30 Minutes)

### Prerequisites
- Android Studio Flamingo+ (or Xcode 14+ for iOS)
- Google/Apple developer account
- Firebase account (free tier OK)

### Step 1: Firebase Setup (5 min)

```bash
# Go to https://console.firebase.google.com/
1. Create project: "connect-center"
2. Add Android app
3. Download google-services.json
4. Save to: Android/ConnectAgentApp/app/google-services.json
```

### Step 2: Build Android (10 min)

```bash
# Navigate to Android project
cd Android/ConnectAgentApp

# Or open in Android Studio:
1. File → Open → Select ConnectAgentApp folder
2. Wait for Gradle sync
3. Build → Build APK(s)
4. Deploy to device
```

### Step 3: Build iOS (10 min)

```bash
# Navigate to iOS project
cd iOS/ConnectCenterUser

# Install dependencies
pod install

# Open workspace
open ConnectCenterUser.xcworkspace

# In Xcode:
1. Select device/simulator
2. Product → Build (⌘B)
3. Product → Run (⌘R)
```

### Step 4: Test (5 min)

```bash
1. Start Android app → Login as agent
2. Start iOS app → Login as user
3. iOS: Tap "Call Support"
4. Android: See incoming call
5. Android: Accept call
6. Both: Connected! ✅
```

---

## Directory Structure

```
connectCenter/
├── iOS/
│   ├── ConnectCenterUser/        ← iOS User App
│   ├── PHASE_2_README.md         ← iOS Setup
│   └── PHASE_2_COMPLETE.md
│
├── Android/
│   ├── ConnectAgentApp/          ← Android Agent App
│   ├── PHASE_3_README.md         ← Android Setup
│   └── PHASE_3_COMPLETE.md
│
├── AWS/
│   └── Documentation/
│       ├── SETUP.md              ← AWS Setup
│       └── CONFIGURATION_CHECKLIST.md
│
├── PROJECT_STATUS.md             ← Overall Status
└── PHASE_3_READY.md              ← This Project Ready
```

---

## Quick Links

| What | Where | Time |
|------|-------|------|
| **Project Status** | [PROJECT_STATUS.md](PROJECT_STATUS.md) | 5 min |
| **Architecture** | [ARCHITECTURE.md](ARCHITECTURE.md) | 10 min |
| **iOS Setup** | [iOS/PHASE_2_README.md](iOS/PHASE_2_README.md) | 5 min |
| **Android Setup** | [Android/PHASE_3_README.md](Android/PHASE_3_README.md) | 5 min |
| **AWS Setup** | [AWS/Documentation/SETUP.md](AWS/Documentation/SETUP.md) | 30 min |
| **Code Details (iOS)** | [iOS/PHASE_2_IMPLEMENTATION_SUMMARY.md](iOS/PHASE_2_IMPLEMENTATION_SUMMARY.md) | 15 min |
| **Code Details (Android)** | [Android/PHASE_3_IMPLEMENTATION_SUMMARY.md](Android/PHASE_3_IMPLEMENTATION_SUMMARY.md) | 15 min |

---

## Technology Stack

### iOS
- Swift 5.7+
- SwiftUI
- AWS SDK for iOS
- Combine (reactive)
- CocoaPods

### Android
- Kotlin 1.8+
- Jetpack Compose
- Firebase Cloud Messaging
- AWS SDK for Android
- Coroutines (async)
- Gradle 8.0+

### AWS
- Amazon Connect (contact center)
- Lambda (optional)
- IAM (authentication)
- CloudWatch (monitoring)

---

## Features at a Glance

### iOS User App ✅
- Call support with one tap
- See call state in real-time
- Mute, speaker, hold, end controls
- Microphone permission handling
- Network connectivity checking

### Android Agent App ✅
- Login with credentials
- See incoming calls via notification
- Accept or reject calls instantly
- Mute, hold, end call controls
- Material Design UI
- Dark mode support

### Integrated Features ✅
- End-to-end call routing
- Real-time state synchronization
- Error handling & recovery
- Production-grade logging
- Secure credential management

---

## Common Issues & Fixes

### "Gradle sync failed"
```bash
# Solution:
1. File → Invalidate Caches → Restart
2. Delete: .gradle folder
3. Retry sync
```

### "google-services.json not found"
```bash
# Solution:
1. Download from Firebase Console
2. Place in: Android/ConnectAgentApp/app/
3. Sync Gradle
```

### "Pod install fails"
```bash
# Solution:
cd iOS/ConnectCenterUser
pod repo update
pod install --repo-update
```

### "Build fails with AWS SDK"
```bash
# Solution:
1. Check iOS deployment target: 14.0+
2. Check Xcode version: 14+
3. Check CocoaPods: pod repo update
```

---

## Performance Tips

### For Faster Builds
```bash
# Android: Use incremental builds
./gradlew assembleDebug --parallel

# iOS: Use incremental compilation
# Already enabled by default in Xcode
```

### For Testing
```bash
# Android: Use emulator with hardware acceleration
emulator -avd Pixel_5_API_30 -gpu on

# iOS: Use simulator (faster than device builds)
# Command line: xcrun simctl list
```

---

## What's Already Done ✅

- ✅ All 18 iOS Swift files (Clean Architecture)
- ✅ All 14+ Android Kotlin files (MVVM)
- ✅ AWS setup documentation (8 phases)
- ✅ Firebase integration ready
- ✅ Error handling throughout
- ✅ Logging infrastructure
- ✅ UI/UX design (Material Design 3)
- ✅ State management (reactive)

---

## What's Next

After building and testing:

1. **Phase 4**: Full end-to-end integration (1-2 days)
2. **Phase 5**: Testing & error handling (2-3 days)
3. **Phase 6**: Bonus features - Customer Profiles, advanced notifications (2-3 days)
4. **Phase 7**: Documentation & demo video (1-2 days)

---

## Support Resources

### Documentation
- [README.md](README.md) - Overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Design
- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Roadmap
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Developer reference

### Phase-Specific
- [iOS/PHASE_2_README.md](iOS/PHASE_2_README.md)
- [Android/PHASE_3_README.md](Android/PHASE_3_README.md)
- [AWS/Documentation/SETUP.md](AWS/Documentation/SETUP.md)

### Troubleshooting
- [PROJECT_STATUS.md](PROJECT_STATUS.md) - Current status
- [PHASE_3_READY.md](PHASE_3_READY.md) - What's ready
- Phase-specific COMPLETE.md files - Validation checklists

---

## Estimated Time Investment

| Task | Time | Who |
|------|------|-----|
| Firebase Setup | 10 min | Dev |
| Android Build | 15 min | Dev |
| iOS Build | 15 min | Dev |
| Run Test | 10 min | Dev |
| AWS Setup | 2-3 hrs | DevOps/Backend |
| End-to-End Test | 1-2 hrs | QA/Dev |
| Total | 4-6 hrs | Team |

---

## Success Criteria ✅

After following this guide:
- [ ] Both apps build without errors
- [ ] Firebase notifications received
- [ ] Agent can log in to Android app
- [ ] User can log in to iOS app
- [ ] Call flow works end-to-end
- [ ] Audio connects between devices

**All criteria met = Phase 3 ✅ Validated**

---

## Next Level

For deeper understanding:
1. Read [ARCHITECTURE.md](ARCHITECTURE.md) - Understand design patterns
2. Review iOS implementation - [iOS/PHASE_2_IMPLEMENTATION_SUMMARY.md](iOS/PHASE_2_IMPLEMENTATION_SUMMARY.md)
3. Review Android implementation - [Android/PHASE_3_IMPLEMENTATION_SUMMARY.md](Android/PHASE_3_IMPLEMENTATION_SUMMARY.md)
4. Set up AWS per [AWS/Documentation/SETUP.md](AWS/Documentation/SETUP.md)

---

**Ready? Start with Firebase setup above or click one of the links above!**

*Last Updated: May 3, 2026*
