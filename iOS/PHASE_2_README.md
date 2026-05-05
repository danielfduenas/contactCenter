# iOS App Setup Guide - Phase 2

## Overview
This is the iOS user-facing application for the Amazon Connect Mobile Integration technical test. Users can tap a button to request support and be connected to an agent via the Android app.

## Architecture
- **Clean Architecture Pattern**: Domain → Data → Presentation layers
- **State Management**: Combine framework with ObservableObject
- **UI Framework**: SwiftUI
- **AWS Integration**: AWS SDK for iOS

## Prerequisites

### Development Environment
- Xcode 14.0 or later
- Swift 5.7+
- iOS 14.0+
- CocoaPods 1.11+

### AWS Setup (Required Before Testing)
- AWS Account with Amazon Connect enabled
- Connect Instance ID
- Queue ID for support calls
- Contact Flow ID
- IAM credentials (Access Key, Secret Key)

## Installation Steps

### 1. Install Dependencies
```bash
cd iOS
pod install
```

### 2. Configure AWS Credentials

Create a `.env` file in the `iOS/ConnectMobileUser` directory (or use environment variables):

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"
export AWS_REGION="us-east-1"
export CONNECT_INSTANCE_ID="your-instance-id"
export CONNECT_QUEUE_ID="your-queue-id"
export CONNECT_CONTACT_FLOW_ID="your-contact-flow-id"
```

Or update [AWSConfiguration.swift](ConnectMobileUser/Utilities/Constants/AWSConfiguration.swift) with your values.

### 3. Open Project
```bash
open ConnectMobileUser.xcworkspace
```

### 4. Build & Run
- Select target device/simulator
- Build: `Cmd + B`
- Run: `Cmd + R`

## Project Structure

```
ConnectMobileUser/
├── App/                          # App lifecycle (AppDelegate, SceneDelegate)
├── Presentation/
│   ├── Views/                   # SwiftUI views
│   │   ├── ContentView.swift
│   │   ├── CallStatusView.swift
│   │   ├── CallButtonView.swift
│   │   └── CallControlsView.swift
│   └── ViewModels/              # State management
│       └── CallViewModel.swift
├── Domain/
│   ├── Entities/                # Business entities
│   │   ├── Call.swift
│   │   ├── CallState.swift
│   │   └── CallError.swift
│   ├── Repositories/            # Repository interfaces
│   │   ├── CallRepository.swift
│   │   └── PermissionRepository.swift
│   └── UseCases/                # Business logic
│       ├── InitiateCallUseCase.swift
│       ├── MonitorCallStatusUseCase.swift
│       └── EndCallUseCase.swift
├── Data/
│   ├── Repositories/            # Repository implementations
│   │   ├── CallRepositoryImpl.swift
│   │   └── PermissionRepositoryImpl.swift
│   ├── DataSources/             # Data fetching layer
│   └── Network/                 # Networking
│       └── AWSConnectClient.swift
└── Utilities/
    ├── Constants/               # Configuration
    │   └── AWSConfiguration.swift
    ├── Extensions/              # Swift extensions
    └── Managers/                # Utilities
        ├── Logger.swift
        └── NetworkReachability.swift
```

## Core Features

### 1. **Call Initiation** (`CallButtonView`)
- User enters name (optional)
- Taps "Call Support" button
- App requests microphone permission
- Call initiated via AWS Connect SDK

### 2. **Call Status Monitoring** (`CallStatusView`)
- Real-time status updates: Connecting → Ringing → Active → Ended
- Display call duration timer
- Show agent name when connected

### 3. **Call Controls** (`CallControlsView`)
- **Mute**: Toggle microphone on/off
- **Speaker**: Switch between speaker and earpiece
- **Hold**: Place call on hold
- **End Call**: Terminate the call

### 4. **Error Handling**
- Network unavailable
- Microphone permission denied
- AWS authentication failed
- Call service errors
- Automatic retry with exponential backoff

### 5. **Permissions Management**
- Request microphone access on first call
- Handle permission denial gracefully
- Link to app settings if needed

## State Diagram

```
IDLE (initial)
  ↓
REQUESTING_PERMISSION → (if denied) → ERROR
  ↓
CONNECTING (AWS API call)
  ↓
RINGING (waiting for agent)
  ↓
ACTIVE (connected to agent)
  ├─ → ON_HOLD
  ├─ → ACTIVE (resumed)
  ↓
ENDING
  ↓
ENDED (final)
```

## Data Flow

### Call Initiation Flow
```
1. User taps "Call Support"
   ↓
2. CallViewModel.initiateCall()
   ↓
3. Check microphone permission
   ├─ If not granted → Request permission
   ├─ If denied → Show error & return
   ↓
4. InitiateCallUseCase.execute()
   ↓
5. CallRepositoryImpl.initiateCall()
   ↓
6. AWSConnectClient.startOutboundVoiceContact()
   ↓
7. AWS SDK calls Amazon Connect API
   ↓
8. Receive contactId → Start monitoring call status
```

### Call Status Monitoring
```
1. monitorCallStatus(contactId)
   ↓
2. Create AsyncStream
   ↓
3. Poll AWS Connect API every 1-5 seconds
   ↓
4. Emit CallState updates to stream
   ↓
5. CallViewModel receives updates
   ↓
6. UI updates automatically (SwiftUI reactivity)
```

## Testing

### Unit Tests
```bash
Cmd + U
```

Test cases include:
- ViewModels state transitions
- Use case execution flows
- Repository mock implementations
- Error handling scenarios

### Manual Testing

1. **Call Initiation**
   - Tap "Call Support"
   - Verify microphone permission prompt
   - Verify call status changes to "Connecting"

2. **Call Status**
   - Check that call transitions to "Active" when agent accepts
   - Verify duration timer increments
   - Verify agent name displays

3. **Call Controls**
   - Test mute toggle
   - Test speaker toggle
   - Test hold functionality

4. **Error Scenarios**
   - Turn off WiFi/cellular → should show network error
   - Deny microphone permission → should show permission error
   - Invalid AWS credentials → should show auth error

5. **End Call**
   - Tap "End Call" during active call
   - Verify status changes to "Ended"
   - Verify can start new call after

## Troubleshooting

### AWS Credentials Not Recognized
- Verify environment variables are set correctly
- Check AWS IAM user has `connect:*` permissions
- Verify region matches your Connect instance region

### Microphone Permission Not Requested
- Check `NSMicrophoneUsageDescription` in Info.plist
- Delete app and reinstall (permissions cache)
- Go to Settings → App → Microphone and toggle

### Call Not Connecting
- Verify Contact Flow is published in Connect console
- Verify Queue exists and has agents available
- Check CloudWatch logs in AWS console

### No Agent Received Call
- Verify agent is logged into Android app
- Verify agent is in correct queue
- Check agent routing profile in Connect console

## Performance Considerations

- **Polling Interval**: Starts at 1s, increases to 5s max
- **Memory**: AsyncStream automatically handles cleanup
- **Battery**: Periodic polling when app in foreground
- **Network**: Exponential backoff for retries

## Security

### Credential Storage
- Never hardcode credentials in code
- Use environment variables or AWS Cognito
- Consider using AWS temporary credentials (STS)
- Credentials stored in Keychain (not included yet, add for production)

### SSL/TLS
- AWS SDK handles certificate validation
- Ensure system certificates are up-to-date

## Next Steps

1. **Phase 3**: Start Android Agent App development
2. **Phase 4**: End-to-end testing (iOS → Android)
3. **Phase 5**: Comprehensive error handling and retry logic
4. **Phase 6**: Push notifications and bonus features

## Dependencies

- **AWSConnect**: Amazon Connect SDK
- **AWSCore**: AWS core SDK
- **Combine**: State management
- **SwiftUI**: UI framework

## References

- [AWS SDK for iOS Documentation](https://docs.aws.amazon.com/sdk-for-ios/)
- [Amazon Connect Developer Guide](https://docs.aws.amazon.com/connect/latest/)
- [SwiftUI Documentation](https://developer.apple.com/swiftui/)
