# Arquitectura del Sistema - Amazon Connect Mobile Integration

## 📐 Diagrama General del Flujo

```
┌─────────────────┐
│   Usuario iOS   │
│ (SwiftUI App)   │
└────────┬────────┘
         │
         │ 1. Toca "Llamar a Soporte"
         │
         ▼
┌─────────────────────────────┐
│  AWS SDK iOS                │
│  - Authentication (SigV4)   │
│  - StartOutboundVoiceContact│
└────────┬────────────────────┘
         │
         │ 2. HTTP/REST Call
         │
         ▼
┌──────────────────────────────┐
│  Amazon Connect Instance     │
│  ┌──────────────────────┐    │
│  │ Contact Flow         │    │
│  │ - Inbound Queue      │    │
│  └────────┬─────────────┘    │
│           │                  │
│           ▼                  │
│  ┌──────────────────────┐    │
│  │ Routing Profile      │    │
│  │ - Route to Queue     │    │
│  └────────┬─────────────┘    │
│           │                  │
│           ▼                  │
│  ┌──────────────────────┐    │
│  │ Agent Queue          │    │
│  │ (Push Notification)  │    │
│  └──────────────────────┘    │
└──────────┬───────────────────┘
           │
           │ 3. Notificación entrante
           │
           ▼
┌─────────────────────┐
│  Agente Android     │
│  (Kotlin App)       │
│  - CCP WebView      │
│  - Firebase FCM     │
└─────────────────────┘
           │
           │ 4. Agente acepta llamada
           │
           ▼
┌─────────────────────────────────┐
│  WebRTC/SIP Bridge              │
│  (Amazon Connect Backend)       │
└────────┬────────────────────────┘
         │
    ┌────┴────┐
    │          │
    ▼          ▼
[iOS Audio] [Android Audio]
(Bidireccional)
```

---

## 🏛️ Arquitectura por Componente

### **1. Capa AWS (Backend)**

#### 1.1 IAM Roles & Policies
```
ConnectUserRole
├── Permissions for GetUserData
├── Permissions for StartOutboundVoiceContact
├── Permissions for GetContactAttributes
└── Permissions for UpdateContactAttributes

MobileAppRole (iOS)
├── sts:AssumeRole (con token temporal)
├── connect:StartOutboundVoiceContact
└── connect:GetContactAttributes

AgentRole (Android)
├── sts:AssumeRole
├── connect:DescribeContact
├── connect:GetContactAttributes
└── connect:UpdateContactAttributes
```

#### 1.2 Contact Flow Architecture
```
Contact Flow: "Mobile User Support"
│
├─ [Entry Point] - Inbound/Outbound
│
├─ [Set Contact Attributes]
│  └─ Source: Mobile App (iOS)
│
├─ [Transfer to Queue]
│  ├─ Queue: "Mobile Support Queue"
│  └─ Routing: Round-robin a agentes disponibles
│
├─ [Add to Queue]
│  ├─ Max wait time: 5 minutos
│  ├─ Callback: Sí (opcional)
│
└─ [Disconnect]
   └─ Logging y analytics
```

#### 1.3 Agent Configuration
```
Routing Profile: "Mobile Support Agent"
├─ Channels: Voice
├─ Queue Assignment:
│  └─ "Mobile Support Queue" → Agent Status (Available/On Contact/After Contact Work)
├─ Available states: Available, On Contact, ACW, Offline
└─ Max concurrent contacts: 1 (voz)

Agent User Account:
├─ Username: agent@company.connect
├─ Role: Agent
├─ Queue Assignment: Mobile Support Queue
└─ Hierarchy: Team/Department
```

---

### **2. Capa iOS (Swift/SwiftUI)**

#### 2.1 Clean Architecture Layers

```
Presentation Layer
├─ Views (SwiftUI)
│  ├─ CallButtonView
│  ├─ CallStatusView
│  └─ CallControlsView
├─ ViewModels
│  └─ CallViewModel
│     ├─ @Published var callState: CallState
│     ├─ @Published var errorMessage: String?
│     ├─ func initiateCall()
│     ├─ func endCall()
│     └─ func updateCallStatus()
└─ Coordinators
   └─ CallFlowCoordinator

Domain Layer
├─ Entities
│  ├─ Call (id, status, duration, etc.)
│  ├─ CallState (enum)
│  └─ CallError (error handling)
├─ UseCases
│  ├─ InitiateCallUseCase
│  ├─ EndCallUseCase
│  ├─ MonitorCallStatusUseCase
│  └─ RequestMicrophonePermissionUseCase
└─ Repositories (Protocols)
   ├─ CallRepository
   └─ PermissionRepository

Data Layer
├─ Repositories (Implementations)
│  ├─ CallRepositoryImpl
│  │  ├─ AWS SDK Integration
│  │  ├─ Network Layer
│  │  └─ Call State Management
│  └─ PermissionRepositoryImpl
│     ├─ AVAudioSession
│     └─ UserDefaults (persistent)
├─ DataSources
│  ├─ RemoteDataSource (AWS Connect API)
│  └─ LocalDataSource (cached call history)
└─ Networking
   ├─ AWSConnectClient (wrapper SDK)
   ├─ URLSession Configuration
   └─ Error Mapping
```

#### 2.2 Key Classes/Structs

```swift
// Domain Entities
enum CallState {
    case idle
    case connecting
    case ringing
    case active(duration: TimeInterval)
    case onHold
    case ending
    case ended(reason: DisconnectReason)
    case error(CallError)
}

enum CallError: Error {
    case networkUnavailable
    case microphonePermissionDenied
    case authenticationFailed
    case connectServiceUnavailable
    case timeout
    case unknown(String)
}

// Data Models
struct Call {
    let id: String
    let contactId: String
    let status: CallState
    let startTime: Date?
    let endTime: Date?
    let agentName: String?
}

// ViewModels
class CallViewModel: ObservableObject {
    @Published var callState: CallState = .idle
    @Published var errorMessage: String?
    @Published var callDuration: TimeInterval = 0
    
    private let initiateCallUseCase: InitiateCallUseCase
    private let permissionManager: PermissionManager
    
    func initiateCall() async {
        // Implementation
    }
}
```

---

### **3. Capa Android (Kotlin/Compose)**

#### 3.1 MVVM Architecture

```
UI Layer (Compose)
├─ Screens
│  ├─ LoginScreen
│  │  ├─ UsernameTextField
│  │  ├─ PasswordTextField
│  │  └─ LoginButton
│  ├─ AgentDashboardScreen
│  │  ├─ IncomingCallCard
│  │  ├─ CallControlsRow
│  │  │  ├─ AcceptButton
│  │  │  ├─ RejectButton
│  │  │  ├─ MuteToggleButton
│  │  │  └─ HoldToggleButton
│  │  └─ CallTimerDisplay
│  └─ CallHistoryScreen
└─ Navigation
   └─ AppNavigation (NavController)

ViewModel Layer
├─ AuthViewModel
│  ├─ login(username, password)
│  ├─ logout()
│  └─ sessionState: StateFlow<SessionState>
├─ CallViewModel
│  ├─ incomingCall: StateFlow<Call?>
│  ├─ callState: StateFlow<CallState>
│  ├─ acceptCall()
│  ├─ rejectCall()
│  ├─ toggleMute()
│  └─ endCall()
└─ NotificationViewModel
   ├─ handleIncomingCallNotification()
   └─ showCallNotification()

Domain Layer (Business Logic)
├─ UseCases
│  ├─ LoginUseCase
│  ├─ AcceptCallUseCase
│  ├─ RejectCallUseCase
│  ├─ GetCallStatusUseCase
│  └─ GetCustomerProfileUseCase (Bonus)
├─ Entities
│  └─ Agent, Call, CallState, etc.
└─ Repositories
   ├─ AuthRepository
│  ├─ CallRepository
│  └─ NotificationRepository

Data Layer
├─ Repositories (Impl)
│  ├─ AuthRepositoryImpl
│  ├─ CallRepositoryImpl (WebView/SDK)
│  └─ NotificationRepositoryImpl
├─ Remote DataSources
│  ├─ ConnectWebViewClient
│  ├─ AmazonConnectSDK
│  └─ FirebaseMessaging (FCM)
├─ Local DataSources
│  ├─ SharedPreferences (encrypted)
│  └─ Room Database (call history)
└─ Models
   ├─ LoginRequest/Response
   ├─ CallData
   └─ AgentData
```

#### 3.2 Key Classes

```kotlin
// Domain Entities
enum class CallState {
    IDLE,
    RINGING,
    CONNECTED,
    MUTED,
    ON_HOLD,
    DISCONNECTING,
    DISCONNECTED
}

data class Call(
    val id: String,
    val contactId: String,
    val callerId: String,
    val callerName: String,
    val state: CallState,
    val duration: Long,
    val timestamp: Long
)

// ViewModel
class CallViewModel(
    private val acceptCallUseCase: AcceptCallUseCase,
    private val rejectCallUseCase: RejectCallUseCase,
    private val callRepository: CallRepository
) : ViewModel() {
    
    private val _callState = MutableStateFlow<CallState>(CallState.IDLE)
    val callState: StateFlow<CallState> = _callState.asStateFlow()
    
    fun acceptCall(contactId: String) {
        viewModelScope.launch {
            acceptCallUseCase(contactId).collect { result ->
                _callState.value = result
            }
        }
    }
}
```

---

## 🔐 Flujo de Autenticación

### iOS
```
1. App inicia
   ├─ Verifica credenciales en Keychain
   ├─ Si existen: Usa SigV4 para firmar requests
   └─ Si no: Usuario ingresa manualmente
2. SigV4 Signing
   ├─ AWS Access Key ID
   ├─ AWS Secret Access Key
   └─ AWS Session Token (temporal)
3. Request a StartOutboundVoiceContact
   ├─ Signed HTTP Header
   └─ Contact attributes (caller info)
```

### Android
```
1. Agent inicia app
2. Pantalla de Login (Cognito o directa)
   ├─ Username/Password
   └─ MFA (opcional)
3. Backend retorna:
   ├─ Session Token
   ├─ CCP WebView URL (con credenciales embebidas)
   └─ User permissions
4. WebView carga CCP
   ├─ JavaScript Bridge
   └─ Event listeners para llamadas
```

---

## 🔄 Integración AWS Lambda (Opcional)

### Presigner Function
```
Propósito: Generar URLs presignadas para WebRTC/SIP
Trigger: Cuando agente inicia sesión

Input:
{
    "agentId": "agent-123",
    "instanceId": "xxxxxxxx-xxxx"
}

Output:
{
    "ccpUrl": "https://instance.awsapps.com/connect/ccp-v2/...",
    "webSocketUrl": "wss://...",
    "expiresIn": 3600
}
```

---

## 📱 Manejo de Estados

### Call States (iOS & Android)
```
IDLE 
  ↓
  ├─ [User/Agent initiates] → CONNECTING
  │                            ↓
  │                        RINGING
  │                            ↓
  │                        CONNECTED
  │                            ├─ [Mute] → MUTED
  │                            ├─ [Hold] → ON_HOLD
  │                            └─ [End] → DISCONNECTING
  │
  └─────────────────────────────────┘
            ↓
      DISCONNECTED (final)
```

---

## 🚨 Error Handling Strategy

```
Network Errors
├─ No connectivity → Show offline message + Retry queue
├─ Timeout (>30s) → Retry with exponential backoff
└─ Invalid certificate → Fail with security warning

Authentication Errors
├─ Invalid credentials → Redirect to login
├─ Expired token → Refresh token flow
└─ Permission denied → Show error dialog

Call Control Errors
├─ Microphone permission denied → Request permission
├─ Agent unavailable → Queue message
└─ Contact not found → End call gracefully

Permission Errors
├─ Microphone → requestUserPermission()
├─ Camera (video) → requestCameraPermission()
└─ Notification → requestNotificationPermission()
```

---

## 📊 Data Flow Diagrams

### iOS: Initiate Call
```
User taps "Call" 
    ↓
CallViewModel.initiateCall()
    ↓
RequestMicrophonePermissionUseCase
    ├─ [If denied] → Show error
    └─ [If granted] → Continue
    ↓
InitiateCallUseCase
    ├─ Validate network connectivity
    ├─ Create SigV4 request
    ├─ Call StartOutboundVoiceContact
    └─ Receive contactId
    ↓
Update CallState → .connecting
    ↓
Poll contact status via GetContactAttributes
    ├─ QUEUED → Show "Waiting for agent"
    ├─ CONNECTED → Show "In call"
    └─ DISCONNECTED → Show "Call ended"
```

### Android: Receive Call
```
Firebase FCM receives notification
    ↓
NotificationService.onMessageReceived()
    ↓
Parse call data (contactId, callerId, etc.)
    ↓
Show IncomingCallNotification
    ├─ Sound + Vibration
    └─ Full-screen notification
    ↓
User accepts/rejects
    ├─ [Accept] → CallViewModel.acceptCall()
    │              ├─ Load CCP WebView
    │              └─ Bridge with JavaScript
    │
    └─ [Reject] → RejectCallUseCase
                   └─ Update contact status
```

---

## 🧪 Testing Strategy

```
Unit Tests
├─ ViewModels (state changes)
├─ UseCases (business logic)
└─ Repositories (mock data)

Integration Tests
├─ AWS SDK calls (mock API)
├─ Authentication flow
└─ Call lifecycle

E2E Tests
├─ iOS initiates call
├─ Connect routes to Android
└─ Audio connection established
```

---

## 📋 Dependencias Principales

### iOS
- AWSConnectParticipant
- AWSConnect
- Combine (state management)
- AVFoundation (audio)

### Android
- Amazon Connect SDK
- Firebase Cloud Messaging
- Jetpack Compose
- Room Database

### AWS
- Amazon Connect
- AWS Lambda
- IAM
- CloudWatch
