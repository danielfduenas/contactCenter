# Plan de Implementación Detallado

## 📅 Fase 1: Infraestructura AWS (3-4 días)

### 1.1 Preparación Inicial
- [ ] Crear cuenta AWS o acceder a cuenta existente
- [ ] Configurar AWS CLI
- [ ] Crear IAM user con permisos necesarios
- [ ] Documentar credenciales en archivo `.env.example`

### 1.2 Amazon Connect Setup
- [ ] Crear instancia de Connect desde consola
  - Instance name: `MobileConnectSupport`
  - Region: `us-east-1` (recomendado para disponibilidad)
  - Inbound calls: Habilitado
  - Outbound calls: Habilitado
  
- [ ] Configurar telefonía
  - Asignar número de teléfono (DID) O usar SIP URI
  
- [ ] Crear usuarios
  - Admin: `admin@company.connect`
  - Agent 1: `agent1@company.connect`
  - Agent 2: `agent2@company.connect` (para testing)

### 1.3 Contact Flow Configuration
- [ ] Crear Contact Flow: "Mobile User Support"
  ```
  Entry → Set contact attributes → Transfer to queue → Add to queue → Disconnect
  ```
  - Capturar source: Mobile
  - Capturar caller info
  - Route to "Mobile Support Queue"

- [ ] Crear segunda Contact Flow: "Agent Dashboard" (para CCP)

### 1.4 Queue & Routing Profile Setup
- [ ] Crear Queue: "Mobile Support Queue"
  - Max wait time: 5 min
  - Enable callback: Yes
  
- [ ] Crear Routing Profile: "Mobile Support Agent"
  - Default outbound queue: Mobile Support Queue
  - Channels: Voice
  - Associate agents: agent1@company.connect, agent2@company.connect

### 1.5 IAM Configuration
- [ ] Crear IAM Role: `ConnectMobileAppRole`
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "connect:StartOutboundVoiceContact",
          "connect:GetContactAttributes",
          "connect:UpdateContactAttributes",
          "connect:GetUserData"
        ],
        "Resource": "arn:aws:connect:*:*:instance/*"
      },
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::ACCOUNT_ID:role/ConnectMobileAppRole"
      }
    ]
  }
  ```

- [ ] Crear IAM Role: `AgentMobileAppRole`
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "connect:DescribeContact",
          "connect:GetContactAttributes",
          "connect:UpdateContactAttributes",
          "connect:GetCCPSessionBag"
        ],
        "Resource": "arn:aws:connect:*:*:instance/*"
      }
    ]
  }
  ```

### 1.6 Testing AWS Setup
- [ ] Verificar que Contact Flow funciona
- [ ] Hacer test call desde interfaz Connect
- [ ] Validar logs en CloudWatch

---

## 📅 Fase 2: iOS App Development (3-4 días)

### 2.1 Proyecto Setup
- [ ] Crear proyecto Xcode (iOS 14+, Swift 5.7+)
- [ ] Configurar CocoaPods/SPM
  ```
  pod 'AWSConnect'
  pod 'AWSConnectParticipant'
  pod 'Combine'
  ```

### 2.2 Project Structure
```
AmazonConnectClient/
├── App/
│   └── AmazonConnectClientApp.swift
├── Presentation/
│   ├── Views/
│   │   ├─ CallButtonView.swift
│   │   ├─ CallStatusView.swift
│   │   └─ ContentView.swift
│   └── ViewModels/
│       └── CallViewModel.swift
├── Domain/
│   ├── Entities/
│   │   └── Call.swift
│   ├── UseCases/
│   │   ├── InitiateCallUseCase.swift
│   │   └── EndCallUseCase.swift
│   └── Repositories/
│       └── CallRepository.swift
├── Data/
│   ├── Repositories/
│   │   └── CallRepositoryImpl.swift
│   ├── DataSources/
│   │   └── AWSConnectDataSource.swift
│   ├── Networking/
│   │   ├── AWSConnectClient.swift
│   │   └── SigV4Signer.swift
│   └── Models/
│       └── StartCallRequest.swift
└── Shared/
    ├── Managers/
    │   └── PermissionManager.swift
    └── Utilities/
        ├── Constants.swift
        └── Logger.swift
```

### 2.3 Core Implementation Files

#### 2.3.1 Domain Layer
- [ ] `Call.swift` - Entity model
- [ ] `CallState.swift` - Enum de estados
- [ ] `CallError.swift` - Error types
- [ ] `CallRepository.swift` - Protocol
- [ ] `InitiateCallUseCase.swift` - Lógica de negocio
- [ ] `EndCallUseCase.swift` - Lógica de negocio

#### 2.3.2 Presentation Layer
- [ ] `CallViewModel.swift`
  - `@Published var callState: CallState`
  - `@Published var errorMessage: String?`
  - `func initiateCall() async`
  - `func endCall() async`
  - Timer para duración

- [ ] `ContentView.swift`
  - SwiftUI main screen
  - Call button
  - Status display
  - Error handling

- [ ] `CallStatusView.swift`
  - Muestra estado actual
  - Botones de control (if connected)
  - Animation

#### 2.3.3 Data Layer
- [ ] `AWSConnectClient.swift`
  - Wrapper del AWS SDK
  - SigV4 signing
  - Error mapping

- [ ] `CallRepositoryImpl.swift`
  - Implementación del protocol
  - Llama a AWS SDK
  - Estado cacheado

- [ ] `PermissionManager.swift`
  - Solicita permisos de micrófono
  - Maneja respuestas

### 2.4 Implementation Checklist
- [ ] Display call button
- [ ] Request microphone permission
- [ ] Sign AWS request (SigV4)
- [ ] Call `StartOutboundVoiceContact`
- [ ] Handle response (contactId)
- [ ] Update UI with call state
- [ ] Poll `GetContactAttributes`
- [ ] Display timer de duración
- [ ] End call functionality
- [ ] Error handling & retry logic

### 2.5 Testing (iOS)
- [ ] Unit tests para ViewModels
- [ ] Mock AWSConnectClient
- [ ] Test permission flows
- [ ] Test call state transitions

---

## 📅 Fase 3: Android App Development (3-4 días)

### 3.1 Project Setup
- [ ] Crear proyecto Android (Kotlin, minSDK 24)
- [ ] Configurar Gradle
  ```gradle
  dependencies {
    implementation 'software.amazon.awssdk:connect:2.x'
    implementation 'com.google.firebase:firebase-messaging:x.x.x'
    implementation 'androidx.compose.ui:ui:x.x.x'
  }
  ```

### 3.2 Project Structure
```
app/src/main/java/com/example/connectagent/
├── ui/
│   ├── screens/
│   │   ├─ LoginScreen.kt
│   │   ├─ AgentDashboardScreen.kt
│   │   └─ CallHistoryScreen.kt
│   ├── components/
│   │   ├─ IncomingCallCard.kt
│   │   ├─ CallControlsRow.kt
│   │   └─ CallTimerDisplay.kt
│   └── navigation/
│       └─ AppNavigation.kt
├── viewmodel/
│   ├── AuthViewModel.kt
│   ├── CallViewModel.kt
│   └── NotificationViewModel.kt
├── domain/
│   ├── entities/
│   │   ├─ Agent.kt
│   │   ├─ Call.kt
│   │   └─ CallState.kt
│   ├── usecases/
│   │   ├─ LoginUseCase.kt
│   │   ├─ AcceptCallUseCase.kt
│   │   └─ RejectCallUseCase.kt
│   └── repositories/
│       ├─ AuthRepository.kt
│       ├─ CallRepository.kt
│       └─ NotificationRepository.kt
├── data/
│   ├── repositories/
│   │   ├─ AuthRepositoryImpl.kt
│   │   └─ CallRepositoryImpl.kt
│   ├── sources/
│   │   ├─ ConnectWebViewClient.kt
│   │   └─ FirebaseMessagingService.kt
│   ├── local/
│   │   ├─ SharedPreferencesManager.kt
│   │   └─ AppDatabase.kt
│   └── models/
│       ├─ LoginRequest.kt
│       ├─ CallData.kt
│       └─ AgentData.kt
└── di/
    └─ AppModule.kt (Dependency Injection)
```

### 3.3 Core Implementation Files

#### 3.3.1 Authentication
- [ ] `LoginScreen.kt`
  - Username/Password fields
  - Login button
  - Error display
  - Loading state

- [ ] `AuthViewModel.kt`
  - Handles login logic
  - Stores session token
  - Manages authentication state

- [ ] `SharedPreferencesManager.kt`
  - Store encrypted credentials
  - Handle token refresh

#### 3.3.2 Call Management
- [ ] `AgentDashboardScreen.kt`
  - Incoming call card (when call arrives)
  - Call controls (Accept/Reject/Mute/Hold/End)
  - Call timer
  - CCP WebView embedded

- [ ] `CallViewModel.kt`
  - Manages call state
  - Handles accept/reject/end logic
  - Manages mute/hold toggles

- [ ] `ConnectWebViewClient.kt`
  - WebView for CCP
  - JavaScript bridge
  - Event listeners

#### 3.3.3 Notifications
- [ ] `FirebaseMessagingService.kt`
  - Handle FCM messages
  - Parse incoming call data
  - Show notification
  - Launch full-screen intent

- [ ] `IncomingCallCard.kt`
  - Display caller info
  - Show caller name/number
  - Accept/Reject buttons

### 3.4 Implementation Checklist
- [ ] Login screen with validation
- [ ] Store session securely
- [ ] Load CCP WebView
- [ ] Firebase messaging setup
- [ ] Show incoming call notification
- [ ] Accept call button → Bridge with WebView
- [ ] Reject call button
- [ ] Mute toggle
- [ ] Hold toggle
- [ ] End call functionality
- [ ] Display call timer
- [ ] Handle missing permissions

### 3.5 Testing (Android)
- [ ] Unit tests para ViewModels
- [ ] Mock repositories
- [ ] Test notification handling
- [ ] Test WebView bridge

---

## 📅 Fase 4: Error Handling & Permissions (2 días)

### 4.1 iOS Error Handling
- [ ] Network error handling with retry logic
- [ ] Microphone permission denial flow
- [ ] Authentication error recovery
- [ ] Timeout handling (>30s)
- [ ] Graceful call disconnection

### 4.2 Android Error Handling
- [ ] Network connectivity check
- [ ] Authentication failure handling
- [ ] Permission denial handling
- [ ] WebView crash recovery
- [ ] Firebase messaging failure

### 4.3 Permissions Implementation
#### iOS
- [ ] `NSMicrophoneUsageDescription` in Info.plist
- [ ] Request microphone on app start or first call
- [ ] Handle user denial
- [ ] Redirect to Settings if denied

#### Android
- [ ] REQUEST_RECORD_AUDIO permission
- [ ] REQUEST_MODIFY_PHONE_STATE permission (if supported)
- [ ] Runtime permission check (API 31+)
- [ ] Show permission rationale

---

## 📅 Fase 5: Testing & Validation (2-3 días)

### 5.1 Unit Tests
- [ ] iOS: 10+ test cases para ViewModels
- [ ] Android: 10+ test cases para ViewModels
- [ ] Mock all external dependencies

### 5.2 Integration Tests
- [ ] iOS: AWS SDK integration
- [ ] Android: WebView + CCP integration
- [ ] Authentication flows

### 5.3 E2E Testing
- [ ] iPhone app initiates call
- [ ] Android app receives notification
- [ ] Agent accepts call
- [ ] Audio connection established
- [ ] Call duration timer works
- [ ] Mute/Hold/End controls work
- [ ] Call disconnects properly

### 5.4 Load Testing
- [ ] Multiple simultaneous calls
- [ ] Agent availability updates
- [ ] Queue handling

---

## 📅 Fase 6: Documentation (1-2 días)

### 6.1 AWS Setup Documentation
- [ ] Step-by-step guide en `AWS/Documentation/SETUP.md`
- [ ] Credenciales necesarias
- [ ] Configuración de Contact Flows con screenshots
- [ ] Troubleshooting guide

### 6.2 iOS App Documentation
- [ ] Architecture overview
- [ ] How to run locally
- [ ] Environment variables needed
- [ ] Dependency installation

### 6.3 Android App Documentation
- [ ] Architecture overview
- [ ] How to build and run
- [ ] Firebase setup instructions
- [ ] WebView configuration

### 6.4 Main README.md
- [ ] Project overview
- [ ] System requirements
- [ ] Quick start guide
- [ ] Architecture diagram
- [ ] API references
- [ ] Contributing guidelines

---

## 🎁 Fase 7: Bonus Features (2 días, Opcional)

### 7.1 Push Notifications (Android)
- [ ] Firebase Cloud Messaging integration
- [ ] Custom notification design
- [ ] Sound + Vibration on incoming call
- [ ] Full-screen notification intent

### 7.2 Customer Profiles (Android)
- [ ] Fetch customer data from Connect
- [ ] Display in agent app
- [ ] Show call history
- [ ] Notes/metadata

### 7.3 Unit Tests (Extended)
- [ ] 100% coverage for business logic
- [ ] Integration test suite
- [ ] Mock data factory

---

## 📊 Implementation Metrics

| Phase | Duration | Tasks | Status |
|-------|----------|-------|--------|
| 1. AWS Infra | 3-4 days | 6 | ⬜ |
| 2. iOS App | 3-4 days | 5 | ⬜ |
| 3. Android App | 3-4 days | 5 | ⬜ |
| 4. Error Handling | 2 days | 3 | ⬜ |
| 5. Testing | 2-3 days | 4 | ⬜ |
| 6. Documentation | 1-2 days | 4 | ⬜ |
| 7. Bonus | 2 days | 3 | ⬜ |
| **Total** | **16-23 days** | **30+** | ⬜ |

---

## 🔑 Key Deliverables Checklist

### Code
- [ ] iOS Xcode project with clean architecture
- [ ] Android Android Studio project with MVVM
- [ ] AWS Lambda function (if used)
- [ ] All source code in Git repository

### Documentation
- [ ] AWS setup guide with screenshots
- [ ] iOS developer guide
- [ ] Android developer guide
- [ ] Main README.md with quick start
- [ ] API documentation
- [ ] Architecture diagrams

### Testing
- [ ] Unit tests (iOS + Android)
- [ ] Integration tests
- [ ] E2E test results
- [ ] Test coverage report

### Demo
- [ ] Video showing end-to-end flow
- [ ] Documented test scenarios
- [ ] Screenshots of each app

---

## 🚀 Success Criteria

✅ **Functional Requirements Met**
- Call flows correctly from iOS → AWS Connect → Android
- Agent receives notification and can accept/reject
- Audio stream established between devices
- All call controls functional (mute, hold, end)

✅ **Code Quality**
- Clean Architecture (iOS) / MVVM (Android) properly implemented
- No magic strings or hardcoded values
- Comprehensive error handling
- Proper logging for debugging

✅ **Security**
- Credentials never stored in plaintext
- AWS credentials signed properly (SigV4)
- HTTPS for all communications
- User data encrypted at rest

✅ **Documentation**
- Clear setup instructions
- Code comments explaining complex logic
- Architecture documentation
- Troubleshooting guide

✅ **Testing**
- Unit tests pass
- Integration tests pass
- E2E flow works end-to-end
- Manual testing completed
