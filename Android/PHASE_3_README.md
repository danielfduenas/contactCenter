# Android Agent App - Phase 3 Setup Guide

## Overview

This is the agent-facing Android application for the Amazon Connect Mobile Integration technical test. Agents can log in and receive incoming calls from iOS users with full call controls (mute, hold, end).

## Architecture

- **MVVM Pattern**: ViewModels manage state, Compose renders UI
- **State Management**: Kotlin Flow with StateFlow
- **UI Framework**: Jetpack Compose
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Contact Control**: CCP WebView integration + AWS SDK

## Prerequisites

### Development Environment
- Android Studio Flamingo+
- Kotlin 1.8+
- Android 7.0+ (API 24)
- Gradle 8.0+
- Firebase project configured

### AWS Setup (Required Before Testing)
- Amazon Connect instance ID
- Agent credentials (username/password)
- Firebase project linked for FCM
- FCM Server Key configured

## Installation Steps

### 1. Clone & Open Project
```bash
cd Android
open ConnectAgentApp/
```
(Or open in Android Studio)

### 2. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create/select project
3. Add Android app to project
4. Download `google-services.json`
5. Place in `app/` directory

### 3. Sync Gradle
- Android Studio: `File → Sync Now`
- Or in terminal: `./gradlew build`

### 4. Configure AWS Credentials
Create `local.properties` or edit code:
```properties
AWS_REGION=us-east-1
CONNECT_INSTANCE_ID=your-instance-id
AGENT_USERNAME=agent1@company.connect
```

### 5. Build & Run
```bash
./gradlew installDebug
# Or use Android Studio: Build → Build Bundle(s) / APK(s) → Build APK(s)
```

Then deploy to device/emulator:
- Run configuration in Android Studio
- Or `adb install app-debug.apk`

## Project Structure

```
ConnectAgentApp/
├── app/
│   ├── src/main/java/com/connectcenter/agent/
│   │   ├── domain/
│   │   │   ├── entities/           # Business models
│   │   │   │   ├── Agent.kt
│   │   │   │   ├── Call.kt
│   │   │   │   └── Session.kt
│   │   │   ├── usecases/           # Business logic
│   │   │   │   ├── CallUseCases.kt
│   │   │   │   └── AuthUseCases.kt
│   │   │   └── repositories/       # Interfaces
│   │   │       ├── CallRepository.kt
│   │   │       ├── AgentRepository.kt
│   │   │       └── AuthRepository.kt
│   │   ├── data/
│   │   │   ├── repositories/       # Implementations
│   │   │   │   ├── CallRepositoryImpl.kt
│   │   │   │   ├── AgentRepositoryImpl.kt
│   │   │   │   └── AuthRepositoryImpl.kt
│   │   │   └── datasource/         # Data sources
│   │   ├── ui/
│   │   │   ├── screens/            # Compose screens
│   │   │   │   ├── LoginScreen.kt
│   │   │   │   └── AgentDashboardScreen.kt
│   │   │   ├── navigation/         # Navigation
│   │   │   │   └── Navigation.kt
│   │   │   └── theme/              # Material Design theme
│   │   │       └── Theme.kt
│   │   ├── viewmodel/              # State management
│   │   │   ├── AuthViewModel.kt
│   │   │   └── CallViewModel.kt
│   │   ├── service/                # FCM & Notifications
│   │   │   ├── CallNotificationService.kt
│   │   │   └── CallNotificationBroadcastReceiver.kt
│   │   ├── MainActivity.kt          # App entry point
│   │   └── utils/                  # Utilities
│   ├── src/main/res/               # Resources
│   ├── src/test/                   # Unit tests
│   ├── src/androidTest/            # Instrumentation tests
│   ├── build.gradle                # Dependencies
│   └── AndroidManifest.xml         # Manifest
└── build.gradle                    # Project config
```

## Core Features Implemented

### 1. **Agent Login** ✅
- Username/password authentication
- Session token management
- Credential persistence (SharedPreferences)
- Token refresh capability

### 2. **Incoming Call Notifications** ✅
- Firebase Cloud Messaging (FCM)
- Full-screen notifications (API 31+)
- Custom ringtone + vibration
- Accept/Reject buttons in notification

### 3. **Dashboard & Call Display** ✅
- Incoming call card with caller name/ID
- Call state indicators (Ringing, Connected, Muted, On Hold)
- Real-time call duration timer
- Caller information display

### 4. **Call Controls** ✅
- **Accept**: Connect to caller
- **Reject**: Decline incoming call
- **Mute**: Toggle microphone
- **Hold**: Place call on hold/resume
- **End Call**: Disconnect cleanly

### 5. **Error Handling** ✅
- Network errors
- Authentication failures
- Call operation failures
- User-friendly error messages

### 6. **Permissions** ✅
- Microphone (RECORD_AUDIO)
- Notifications (POST_NOTIFICATIONS)
- Network access (INTERNET)
- Audio modifications (MODIFY_AUDIO_SETTINGS)

## State Diagram

```
LOGIN SCREEN
    ↓ (login success)
AGENT DASHBOARD (idle)
    ↓ (incoming call notification)
INCOMING CALL CARD (ringing)
    ├─ ACCEPT
    │   ↓
    │   CONNECTED (can mute, hold)
    │   ├─ MUTE
    │   ├─ HOLD
    │   └─ END CALL
    │       ↓
    │       DISCONNECTED
    │
    └─ REJECT
        ↓
        IDLE

LOGOUT
    ↓
LOGIN SCREEN
```

## Data Flow

### 1. Login Flow
```
User enters credentials
  ↓
AuthViewModel.login()
  ↓
LoginUseCase.invoke()
  ↓
AuthRepositoryImpl.login()
  ↓
AWS Connect Authentication
  ↓
Return SessionState + Token
  ↓
Save to SharedPreferences
  ↓
Navigate to Dashboard
```

### 2. Incoming Call Flow
```
Firebase FCM receives notification
  ↓
CallNotificationService.onMessageReceived()
  ↓
Parse call data (contactId, callerName, etc.)
  ↓
Show incoming call notification
  ↓
User taps Accept/Reject
  ↓
CallNotificationBroadcastReceiver.onReceive()
  ↓
Launch MainActivity or call useCase
  ↓
CallViewModel.acceptCall() / rejectCall()
  ↓
CallRepositoryImpl makes AWS API call
  ↓
UI updates to show connected call
```

### 3. Call Control Flow
```
User taps "Mute" button
  ↓
CallViewModel.toggleMute()
  ↓
ToggleMuteUseCase.invoke()
  ↓
CallRepositoryImpl.toggleMute()
  ↓
AWS SDK / WebView toggles mute
  ↓
Return success/failure
  ↓
UI updates mute state icon
```

## Testing

### Unit Tests
```bash
./gradlew test
```

Test ViewModels, UseCases, Repositories with mocks.

### Instrumentation Tests
```bash
./gradlew connectedAndroidTest
```

Test on device/emulator.

### Manual Testing

1. **Login**
   - Enter agent credentials
   - Verify login success

2. **Receive Incoming Call**
   - Simulate call from iOS app or manually send FCM notification
   - Verify notification appears
   - Verify call card shows on dashboard

3. **Accept Call**
   - Tap Accept button
   - Verify UI shows connected state

4. **Call Controls**
   - Test Mute toggle
   - Test Hold toggle
   - Test End Call

5. **Error Scenarios**
   - Turn off WiFi → error handling
   - Invalid credentials → show error
   - Network timeout → retry logic

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create Project"
3. Enter project name: `connect-center`
4. Enable Analytics

### 2. Add Android App
1. Click "Add App" → "Android"
2. Enter package name: `com.connectcenter.agent`
3. Download `google-services.json`
4. Place in `app/google-services.json`

### 3. Set Up Cloud Messaging
1. Go to Project Settings → Cloud Messaging
2. Copy Server Key and Sender ID
3. Configure in backend to send messages

### 4. Test FCM Token
- FCM token logged when app starts
- Send test notification from Firebase Console

## Permissions & AndroidManifest

Required permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
```

Runtime permissions handled by Android 6+ (automatic in this app).

## Troubleshooting

### Gradle Sync Fails
- Delete `.gradle` folder: `rm -rf .gradle`
- Delete `build` folder: `rm -rf build`
- Sync again in Android Studio

### Firebase Configuration Not Found
- Verify `google-services.json` is in `app/` directory
- Verify Firebase plugin in `build.gradle`

### FCM Notifications Not Received
- Verify FCM Server Key configured
- Check device is registered (token logged in logcat)
- Verify notification payload format

### Login Fails
- Verify agent credentials are correct
- Check agent exists in Connect instance
- Verify AWS credentials/permissions
- Check network connectivity

### App Crashes
- Check logcat for errors: `adb logcat | grep ConnectCenter`
- Verify all dependencies installed
- Verify Android SDK versions match

## Performance Considerations

- **FCM**: Real-time push notifications
- **Polling**: Periodic status checks (if WebView used)
- **Memory**: Coroutines + Flow for efficient state management
- **Battery**: Notification listener in background

## Security

### Credentials
- Session token stored in SharedPreferences
- **For production**: Use EncryptedSharedPreferences or Keystore
- **Never** hardcode credentials

### Permissions
- Microphone access required for audio
- User grants at login time (Android 6+)

### Network
- HTTPS for all AWS Connect API calls
- SSL/TLS certificate validation
- No cleartext traffic allowed

## Next Steps

1. **Phase 4**: End-to-end testing (iOS → Android)
2. **Phase 5**: Comprehensive error handling & tests
3. **Bonus**: Customer Profiles, enhanced notifications, call history

## References

- [Android Development](https://developer.android.com/)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Amazon Connect SDK](https://docs.aws.amazon.com/connect/latest/)
- [Kotlin Coroutines](https://kotlinlang.org/docs/coroutines-overview.html)

---

**Status**: Phase 3 ✅ Complete  
**Next Phase**: Phase 4 (Integration Testing)  
**Last Updated**: May 3, 2026
