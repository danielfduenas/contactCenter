# Phase 2: iOS App - Quick Start Guide

## 📊 What Was Created

```
iOS/
├── Podfile                              ← Dependencies (AWS SDK, testing)
├── .gitignore                           ← Git ignore rules
├── PHASE_2_README.md                    ← Full setup guide
├── PHASE_2_IMPLEMENTATION_SUMMARY.md    ← Technical summary
└── ConnectMobileUser/
    ├── App/
    │   ├── AppDelegate.swift            ← AWS SDK initialization
    │   └── SceneDelegate.swift          ← SwiftUI scene setup
    │
    ├── Presentation/
    │   ├── Views/
    │   │   ├── ContentView.swift        ← Main container
    │   │   ├── CallStatusView.swift     ← Status display
    │   │   ├── CallButtonView.swift     ← Call initiation
    │   │   └── CallControlsView.swift   ← Call controls (mute, hold, end)
    │   └── ViewModels/
    │       └── CallViewModel.swift      ← State management
    │
    ├── Domain/
    │   ├── Entities/
    │   │   ├── Call.swift               ← Call data model
    │   │   ├── CallState.swift          ← State enum
    │   │   └── CallError.swift          ← Error enum
    │   ├── Repositories/
    │   │   ├── CallRepository.swift     ← Call operations interface
    │   │   └── PermissionRepository.swift ← Permission interface
    │   └── UseCases/
    │       ├── InitiateCallUseCase.swift
    │       ├── MonitorCallStatusUseCase.swift
    │       └── EndCallUseCase.swift
    │
    ├── Data/
    │   ├── Network/
    │   │   └── AWSConnectClient.swift   ← AWS SDK wrapper
    │   ├── Repositories/
    │   │   ├── CallRepositoryImpl.swift  ← Call operations
    │   │   └── PermissionRepositoryImpl.swift ← Permission handling
    │   └── DataSources/                 ← (for future expansion)
    │
    └── Utilities/
        ├── Constants/
        │   └── AWSConfiguration.swift   ← AWS config loader
        ├── Extensions/                  ← (for future extensions)
        └── Managers/
            ├── Logger.swift             ← Centralized logging
            └── NetworkReachability.swift ← Network check
```

## 🚀 Quick Setup (5 minutes)

### Step 1: Install Dependencies
```bash
cd iOS
pod install
```

### Step 2: Configure AWS
```bash
# Set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_SESSION_TOKEN="your-token"
export AWS_REGION="us-east-1"
export CONNECT_INSTANCE_ID="your-instance"
export CONNECT_QUEUE_ID="your-queue"
export CONNECT_CONTACT_FLOW_ID="your-flow"
```

Or directly edit [AWSConfiguration.swift](ConnectMobileUser/Utilities/Constants/AWSConfiguration.swift).

### Step 3: Open in Xcode
```bash
open ConnectMobileUser.xcworkspace
```

### Step 4: Build & Run
- Select target device (simulator or device)
- Press `Cmd + B` to build
- Press `Cmd + R` to run

---

## 📋 File Overview

### Most Important Files (Start Here)

1. **[CallViewModel.swift](ConnectMobileUser/Presentation/ViewModels/CallViewModel.swift)**
   - Main state container
   - Handles call initiation and monitoring
   - Manages duration timer

2. **[CallButtonView.swift](ConnectMobileUser/Presentation/Views/CallButtonView.swift)**
   - User interface for starting calls
   - Name input field
   - Call initiation button

3. **[AWSConnectClient.swift](ConnectMobileUser/Data/Network/AWSConnectClient.swift)**
   - AWS SDK integration
   - Makes API calls to Amazon Connect

4. **[CallRepositoryImpl.swift](ConnectMobileUser/Data/Repositories/CallRepositoryImpl.swift)**
   - Implements call operations
   - Uses AWSConnectClient
   - Manages async status polling

---

## 🔄 How It Works

### User Flow
```
App Launches
  ↓
User taps "Call Support"
  ↓
App requests microphone permission
  ↓
CallViewModel.initiateCall() called
  ↓
InitiateCallUseCase checks permissions & initiates call
  ↓
AWSConnectClient calls AWS Connect API
  ↓
AWS routes call to agent queue
  ↓
App polls for status updates
  ↓
UI updates: Connecting → Ringing → Active
  ↓
User sees agent name and call duration
  ↓
User can mute/hold/speaker
  ↓
User taps End Call
  ↓
Call ends, app returns to idle
```

---

## 🧪 Testing the App

### In Xcode Simulator

1. **Build & Run**
   ```bash
   Cmd + B  # Build
   Cmd + R  # Run
   ```

2. **Test Call Initiation**
   - Enter your name (optional)
   - Tap "Call Support"
   - Grant microphone permission
   - Verify status shows "Connecting..."

3. **Monitor Logs**
   - Open Console: `Cmd + Shift + 2`
   - Look for "Call initiated with contact ID..."

### With Real AWS

1. **Verify AWS Setup** (see [AWS Setup Guide](../AWS/Documentation/SETUP.md))
2. **Start Android Agent App** (Phase 3)
3. **Initiate Call from iOS**
4. **Check if Android receives notification**

---

## ⚙️ Key Architecture Decisions

### Clean Architecture
- **Separation of Concerns**: Domain → Data → Presentation
- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes isolated to specific layers

### State Management
- **SwiftUI + Combine**: Modern, reactive approach
- **ViewModels**: Single source of truth for UI state
- **Publishers**: Automatic UI updates when state changes

### Error Handling
- **Custom Error Enum**: All errors wrapped in `CallError`
- **User-Friendly Messages**: Non-technical error text
- **Retry Logic**: Exponential backoff for network errors

### Async/Await
- **Modern Swift**: Cleaner than completion handlers
- **AsyncStream**: Real-time status updates
- **Automatic Cleanup**: Stream cleans up when call ends

---

## 🔗 Integration Points

### AWS Connect
- Must have instance with queue and contact flow
- IAM credentials needed for API calls
- Instance ID, queue ID, and flow ID required

### Android Agent App (Phase 3)
- Receives call notifications via FCM
- Can accept/reject calls
- Audio connects to iOS user

### Backend Lambda (Optional)
- Generates presigned URLs for WebRTC
- Manages credentials and sessions
- Not required for basic functionality

---

## 📊 State Transitions

```
START: idle
  │
  ├─ user taps button ─→ requestingPermission
  │                            │
  │                    ┌───────┴───────┐
  │                    │               │
  │            permission      permission
  │            granted          denied
  │                │               │
  │                ↓               ↓
  │            connecting  → error (exit)
  │                │
  │                ↓
  │            ringing
  │                │
  │                ↓
  │            active ←──── (streaming status)
  │                │
  │        ┌───────┼───────┐
  │        │       │       │
  │        ↓       ↓       ↓
  │      mute  speaker  hold
  │        │       │       │
  │        └───────┴───────┘
  │                │
  │                ↓
  │            ending
  │                │
  │                ↓
  │            ended (terminal)
  │
  └─────────────────────────────────────
    (returns to START)
```

---

## 🔐 Security Notes

### Credentials
- Currently loaded from environment variables
- **For production**: Use AWS Cognito or STS temporary credentials
- Never hardcode secrets in code
- Use Keychain for local storage

### Permissions
- Microphone permission required for calls
- Handled gracefully if denied
- User can enable in Settings → App → Microphone

### Network
- AWS SDK validates SSL/TLS certificates
- Recommend VPN for development
- Ensure WiFi or cellular connectivity

---

## 📈 Next Steps

### Immediate
- [ ] Install dependencies (`pod install`)
- [ ] Configure AWS credentials
- [ ] Build and run in simulator
- [ ] Test call initiation flow

### Phase 3
- [ ] Start Android app development
- [ ] Set up Firebase Cloud Messaging
- [ ] Implement agent dashboard

### Phase 4
- [ ] End-to-end testing (iOS → Android)
- [ ] Test error scenarios
- [ ] Validate audio connection

### Phase 5+
- [ ] Add unit tests (70%+ coverage)
- [ ] Implement bonus features
- [ ] Create demo video

---

## 📚 File Purposes at a Glance

| File | Purpose |
|------|---------|
| CallViewModel | Manages call state and operations |
| CallButtonView | UI for starting calls |
| CallStatusView | Displays current call state |
| CallControlsView | Mute, hold, speaker, end call buttons |
| CallState | Enum of all possible call states |
| CallError | Enum of all possible errors |
| Call | Data model for a call |
| InitiateCallUseCase | Business logic for call initiation |
| MonitorCallStatusUseCase | Business logic for status monitoring |
| EndCallUseCase | Business logic for ending call |
| CallRepository | Interface for call operations |
| PermissionRepository | Interface for permission operations |
| CallRepositoryImpl | Implementation of call operations |
| PermissionRepositoryImpl | Implementation of permission operations |
| AWSConnectClient | AWS SDK wrapper |
| AWSConfiguration | Loads AWS configuration |
| Logger | Centralized logging |
| NetworkReachability | Network connectivity check |

---

## 🆘 Troubleshooting

### "No AWS credentials found"
- Set environment variables before running Xcode
- Or edit AWSConfiguration.swift with your credentials

### "Pod install fails"
- Delete Pods folder: `rm -rf Pods`
- Delete Podfile.lock: `rm Podfile.lock`
- Run again: `pod install`

### "Microphone permission not requested"
- Check Info.plist has NSMicrophoneUsageDescription key
- Delete app and reinstall
- Or go to Settings and reset app permissions

### "Call not initiated"
- Verify AWS credentials are correct
- Check Connect instance ID and queue ID
- Verify Contact Flow is published in AWS
- Check CloudWatch logs in AWS console

---

## 💡 Tips

- Use `Logger.shared.info()` for debugging
- Open Console in Xcode to see logs
- Use breakpoints in ViewModels for state debugging
- Test with real AWS instance for accurate behavior

---

**Status**: Phase 2 ✅ Complete
**Next Phase**: Android App (Phase 3)
**Last Updated**: 2026-05-03
