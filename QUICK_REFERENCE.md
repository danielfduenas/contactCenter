# Quick Reference Guide for Developers

## 🎯 5-Minute Overview

### What Are We Building?
A system where:
1. **User (iOS)** taps "Call Support" 
2. Call routes through **AWS Amazon Connect**
3. **Agent (Android)** receives notification and accepts
4. Voice connection established between both devices

### Key Technologies
- **iOS**: Swift + SwiftUI + AWS SDK
- **Android**: Kotlin + Jetpack Compose + Firebase FCM
- **Backend**: Amazon Connect + Lambda
- **Architecture Patterns**: Clean Architecture (iOS), MVVM (Android)

---

## 📁 File Structure Quick Map

```
pruebaAmazonConnect/
├── README.md                          # Start here
├── ARCHITECTURE.md                    # System design
├── IMPLEMENTATION_PLAN.md             # Step-by-step tasks
│
├── AWS/
│   ├── Documentation/
│   │   ├── SETUP.md                   # How to setup AWS
│   │   └── CONFIGURATION_CHECKLIST.md # Validation steps
│   ├── CloudFormation/
│   │   └── connect-setup.yaml         # Infrastructure as Code
│   └── Lambda/
│       └── presigner-function.py      # Token generation
│
├── iOS/
│   ├── README.md                      # iOS-specific guide
│   └── AmazonConnectClient/           # Xcode project
│
└── Android/
    ├── README.md                      # Android-specific guide
    └── app/                           # Android Studio project
```

---

## 🔄 Main Data Flow

```
iOS User initiates call
    ↓
[Sign request with SigV4]
    ↓
AWS API: StartOutboundVoiceContact()
    ↓
Amazon Connect:
  ├─ Validate contact flow
  ├─ Create contact
  └─ Route to queue
    ↓
Android Agent receives FCM notification
    ↓
[Agent accepts]
    ↓
WebRTC bridge established
    ↓
Audio stream between iOS ↔ Android
    ↓
[Agent ends call]
    ↓
Contact disconnected
```

---

## 🏗️ Architecture Patterns

### iOS (Clean Architecture)
```
Presentation (Views + ViewModels)
        ↓
Domain (UseCases + Entities)
        ↓
Data (Repositories + Network)
```

**Key Files to Create**:
- `CallViewModel.swift` - Manages call state
- `InitiateCallUseCase.swift` - Business logic
- `AWSConnectClient.swift` - Network wrapper
- `CallRepositoryImpl.swift` - Data access

### Android (MVVM)
```
UI Layer (Screens + Compose)
        ↓
ViewModel Layer (State management)
        ↓
Domain Layer (UseCases)
        ↓
Data Layer (Repositories)
```

**Key Files to Create**:
- `CallViewModel.kt` - State management
- `AcceptCallUseCase.kt` - Business logic
- `CallRepositoryImpl.kt` - Data access
- `FirebaseMessagingService.kt` - Push notifications

---

## 🔑 Critical Identifiers to Obtain

These MUST be obtained from AWS setup (Phase 1):

| ID | Example | Used In |
|----|---------|---------|
| Instance ID | `xxxxxxxx-xxxx-xxxx` | Both apps |
| Contact Flow ID | `yyyyyyyy-yyyy-yyyy` | iOS app |
| Queue ID | `zzzzzzzz-zzzz-zzzz` | AWS config |
| Routing Profile ID | `rrrrrrrr-rrrr-rrrr` | Android login |
| AWS Region | `us-east-1` | Both apps |
| AWS Access Key | `AKIA...` | Both apps |
| AWS Secret Key | `...` | Both apps |

---

## 📱 iOS Implementation Checklist

### Phase 1: Setup
- [ ] Create Xcode project (iOS 14+, Swift 5.7+)
- [ ] Add AWS SDK via CocoaPods
- [ ] Create Constants.swift with AWS values

### Phase 2: Domain Layer
- [ ] Create `Call.swift` (entity)
- [ ] Create `CallState.swift` (enum)
- [ ] Create `CallRepository.swift` (protocol)
- [ ] Create `InitiateCallUseCase.swift`

### Phase 3: Presentation Layer
- [ ] Create `CallViewModel.swift`
- [ ] Create `ContentView.swift` (main UI)
- [ ] Create call button with states
- [ ] Add state display and timer

### Phase 4: Data Layer
- [ ] Create `AWSConnectClient.swift` (wrapper)
- [ ] Implement SigV4 signing
- [ ] Create `CallRepositoryImpl.swift`
- [ ] Create `PermissionManager.swift`

### Phase 5: Testing & Polish
- [ ] Unit tests for ViewModels
- [ ] Mock AWS client for testing
- [ ] Error handling implementation
- [ ] Permission request flows

---

## 🤖 Android Implementation Checklist

### Phase 1: Setup
- [ ] Create Android Studio project (API 24+, Kotlin 1.8+)
- [ ] Configure Gradle dependencies
- [ ] Setup Firebase project

### Phase 2: Domain Layer
- [ ] Create `Call.kt` (data class)
- [ ] Create `CallState.kt` (enum)
- [ ] Create `AuthRepository.kt` (interface)
- [ ] Create `CallRepository.kt` (interface)

### Phase 3: Presentation Layer
- [ ] Create `LoginScreen.kt` (Compose)
- [ ] Create `AgentDashboardScreen.kt`
- [ ] Create `IncomingCallCard.kt`
- [ ] Create call controls (Accept/Reject/Mute/End)

### Phase 4: Data Layer
- [ ] Create `AuthRepositoryImpl.kt`
- [ ] Create `CallRepositoryImpl.kt`
- [ ] Create `FirebaseMessagingService.kt`
- [ ] Create `ConnectWebViewClient.kt`

### Phase 5: Testing & Polish
- [ ] Unit tests for ViewModels
- [ ] Firebase messaging tests
- [ ] Error handling implementation
- [ ] Permission handling

---

## 🛠️ Common Code Patterns

### iOS: AWS Request Signing
```swift
// Pattern for signing AWS requests
let signer = SigV4Signer(
    accessKey: Constants.accessKeyID,
    secretKey: Constants.secretAccessKey
)
let signedRequest = signer.sign(request)
// Execute signedRequest
```

### iOS: Async/Await Pattern
```swift
// MVVM pattern in ViewModels
@MainActor
class CallViewModel: ObservableObject {
    @Published var callState: CallState = .idle
    
    func initiateCall() async {
        do {
            let result = try await useCase.execute()
            self.callState = .connecting
        } catch {
            self.callState = .error(error)
        }
    }
}
```

### Android: StateFlow Pattern
```kotlin
// MVVM state management
class CallViewModel : ViewModel() {
    private val _callState = MutableStateFlow<CallState>(CallState.IDLE)
    val callState: StateFlow<CallState> = _callState.asStateFlow()
    
    fun acceptCall(contactId: String) {
        viewModelScope.launch {
            _callState.value = CallState.CONNECTING
            // acceptance logic
        }
    }
}
```

### Android: Compose UI Pattern
```kotlin
@Composable
fun IncomingCallCard(call: Call, onAccept: () -> Unit) {
    Card {
        Column {
            Text("Call from ${call.callerName}")
            Button(onClick = onAccept) {
                Text("Accept")
            }
        }
    }
}
```

---

## 🚨 Error Handling Strategy

### iOS Errors to Handle
```
❌ Network unavailable → Retry with backoff
❌ Microphone denied → Show permission request
❌ Auth failed → Redirect to setup
❌ Timeout > 30s → Cancel and notify user
❌ Contact not found → Graceful disconnect
```

### Android Errors to Handle
```
❌ Login invalid → Show error dialog
❌ FCM not available → Use polling fallback
❌ WebView crash → Reload CCP
❌ Agent unavailable → Queue user
❌ Call error → Show error notification
```

---

## 🧪 Testing Strategy

### iOS Unit Tests
```swift
// Test InitiateCallUseCase
let mockRepository = MockCallRepository()
let useCase = InitiateCallUseCase(repository: mockRepository)
let result = await useCase.execute()
XCTAssertEqual(result.state, .connecting)
```

### Android Unit Tests
```kotlin
// Test CallViewModel
val repository = mockk<CallRepository>()
val viewModel = CallViewModel(repository)
viewModel.acceptCall("contact-123")
assertEquals(viewModel.callState.value, CallState.CONNECTING)
```

### E2E Test Flow
```
1. Start both apps
2. Click "Call Support" on iOS
3. Verify notification on Android
4. Accept call on Android
5. Verify connected state on both
6. End call and verify disconnected
```

---

## 🔐 Security Checklist

### Credentials
- [ ] AWS keys NOT in source code
- [ ] Use .env files for local development
- [ ] Use environment variables in CI/CD
- [ ] Rotate keys regularly

### Permissions
- [ ] Microphone permission requested (iOS/Android)
- [ ] Camera permission if video (future)
- [ ] Notification permission (Android)

### Network
- [ ] HTTPS only (no HTTP)
- [ ] Certificate pinning (optional)
- [ ] Request signing (SigV4)

### Storage
- [ ] Sensitive data encrypted
- [ ] Use Keychain (iOS) / EncryptedSharedPrefs (Android)
- [ ] Clear cache on logout

---

## 📊 Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Call initiation | < 3 seconds | iOS to notification sent |
| Agent response | < 2 seconds | From tap to WebRTC start |
| Audio latency | < 500ms | End-to-end delay |
| Battery impact | < 5% per hour | On active call |
| Memory usage | < 150MB | App in foreground |
| Notification delay | < 5 seconds | FCM delivery |

---

## 🎁 Bonus Features Priority

| Feature | Complexity | Impact | Priority |
|---------|-----------|--------|----------|
| Push Notifications | Medium | High | 1st |
| Customer Profiles | Medium | Medium | 2nd |
| Unit Tests | Medium | High | 3rd |
| Video Calls | High | Medium | 4th |
| Call Recording | High | Medium | 5th |
| CRM Integration | High | Low | 6th |

---

## 🔗 Important URLs & Resources

### AWS Documentation
- [Amazon Connect API](https://docs.aws.amazon.com/connect/)
- [AWS SDK for iOS](https://github.com/aws-amplify/aws-sdk-ios)
- [AWS SDK for Android](https://github.com/aws-amplify/aws-sdk-android)

### iOS Resources
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession)

### Android Resources
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [ViewModel & LiveData](https://developer.android.com/topic/libraries/architecture/viewmodel)

---

## 📞 Troubleshooting Checklist

### iOS Not Connecting to AWS
- [ ] Check Internet connectivity
- [ ] Verify AWS credentials in Constants.swift
- [ ] Check SigV4 signing implementation
- [ ] Verify Instance ID matches AWS

### Android Not Receiving Calls
- [ ] Check Firebase setup and google-services.json
- [ ] Verify FCM token is being sent to backend
- [ ] Check foreground service permission (Android 12+)
- [ ] Verify agent is "Available" in CCP

### AWS Setup Issues
- [ ] Instance is ACTIVE (not CREATING or FAILED)
- [ ] Contact Flow is PUBLISHED
- [ ] Queue exists and is assigned to routing profile
- [ ] Agent has correct routing profile

---

## 📋 Phase Completion Criteria

### ✅ Phase 1: AWS Setup
- Instance created and active
- Users registered
- Contact flows published
- IAM roles configured

### ✅ Phase 2: iOS App
- Project compiles without errors
- Call button functional
- State transitions work
- Permissions handled

### ✅ Phase 3: Android App
- Project compiles without errors
- Login functional
- Notifications received
- CCP loads in WebView

### ✅ Phase 4: Integration
- iOS initiates call
- Android receives notification
- Call connects end-to-end
- Audio streams work

### ✅ Phase 5: Testing
- All unit tests pass
- Integration tests pass
- E2E flow validated
- Documentation complete

---

**Version**: 1.0  
**Last Updated**: May 2, 2026  
**Difficulty Level**: Advanced  
**Estimated Time**: 3-5 weeks
