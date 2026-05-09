import SwiftUI
import Combine

/// Main view model for managing call state and operations
@MainActor
class CallViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var callState: CallState = .idle {
        didSet {
            logger.info("📱 CallState changed to: \(callState)")
        }
    }
    @Published var errorMessage: String? = nil
    @Published var callDuration: TimeInterval = 0
    @Published var currentCall: Call? = nil
    @Published var showErrorAlert = false
    
    // MARK: - Private Properties
    
    private let initiateCallUseCase: InitiateCallUseCase
    private let monitorCallStatusUseCase: MonitorCallStatusUseCase
    private let endCallUseCase: EndCallUseCase
    private let permissionRepository: PermissionRepository
    private let logger = Logger.shared
    
    private var durationTimer: Timer? = nil
    private var statusTask: Task<Void, Never>? = nil
    
    // Configuration
    private let instanceId: String
    private let queueId: String
    private let contactFlowId: String
    
    // MARK: - Initializer
    
    init(
        instanceId: String,
        queueId: String,
        contactFlowId: String,
        initiateCallUseCase: InitiateCallUseCase,
        monitorCallStatusUseCase: MonitorCallStatusUseCase,
        endCallUseCase: EndCallUseCase,
        permissionRepository: PermissionRepository
    ) {
        self.instanceId = instanceId
        self.queueId = queueId
        self.contactFlowId = contactFlowId
        self.initiateCallUseCase = initiateCallUseCase
        self.monitorCallStatusUseCase = monitorCallStatusUseCase
        self.endCallUseCase = endCallUseCase
        self.permissionRepository = permissionRepository
        
        logger.info("🏗️ CallViewModel initialized with InstanceID: \(instanceId)")
    }
    
    // MARK: - Public Methods
    
    func initiateCall(callerName: String? = nil) async {
        logger.info("🔘 Initiate Call button pressed")
        callState = .requestingPermission
        
        do {
            // Step 1: Check and request permissions
            logger.info("🎤 Checking microphone permissions...")
            let hasPermission = permissionRepository.isMicrophonePermissionGranted()
            if !hasPermission {
                logger.info("⚠️ Permission not granted, requesting...")
                let granted = try await permissionRepository.requestMicrophonePermission()
                if !granted {
                    callState = .error(.microphonePermissionDenied)
                    errorMessage = CallError.microphonePermissionDenied.displayText
                    showErrorAlert = true
                    logger.error("❌ Microphone permission denied by user")
                    return
                }
            }
            logger.info("✅ Microphone permissions secured")
            
            // Step 2: Initiate the call
            callState = .connecting
            logger.info("📞 Executing initiateCallUseCase...")
            
            let contactId = try await initiateCallUseCase.execute(
                instanceId: instanceId,
                queueId: queueId,
                callerName: callerName
            )
            
            logger.info("🚀 Call initiated successfully. Contact ID: \(contactId)")
            
            // Step 3: Create call object and start monitoring
            currentCall = Call(contactId: contactId, status: .connecting)
            monitorCallStatus(contactId: contactId)
            
        } catch let error as CallError {
            callState = .error(error)
            errorMessage = error.displayText
            showErrorAlert = true
            logger.error("❌ Call initiation failed (CallError): \(error.displayText)")
        } catch {
            let callError = CallError.unknown(error.localizedDescription)
            callState = .error(callError)
            errorMessage = callError.displayText
            showErrorAlert = true
            logger.error("❌ Unexpected error during call initiation: \(error)")
        }
    }
    
    func endCall() async {
        guard let contactId = currentCall?.contactId else {
            logger.warning("⚠️ No active call to end")
            return
        }
        
        logger.info("🔌 Ending call for Contact ID: \(contactId)")
        callState = .ending
        
        do {
            let success = try await endCallUseCase.execute(contactId: contactId)
            if success {
                callState = .ended(reason: .userInitiated)
                stopDurationTimer()
                logger.info("✅ Call ended successfully by user")
            } else {
                logger.warning("⚠️ Call end returned false from AWS")
            }
        } catch let error as CallError {
            callState = .error(error)
            errorMessage = error.displayText
            showErrorAlert = true
            logger.error("❌ Error ending call: \(error.displayText)")
        } catch {
            let callError = CallError.unknown(error.localizedDescription)
            callState = .error(callError)
            errorMessage = callError.displayText
            showErrorAlert = true
            logger.error("❌ Unexpected error ending call: \(error)")
        }
    }
    
    func dismissError() {
        logger.info("🧹 Dismissing error alert")
        errorMessage = nil
        showErrorAlert = false
        
        if case .error = callState {
            callState = .idle
            currentCall = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func monitorCallStatus(contactId: String) {
        logger.info("📡 Starting call monitoring task...")
        statusTask = Task {
            for await status in monitorCallStatusUseCase.execute(contactId: contactId) {
                logger.info("🔄 Monitor updated status: \(status)")
                callState = status
                
                switch status {
                case .active:
                    startDurationTimer()
                    logger.info("⏱️ Call is now active, timer started")
                case .ended, .error:
                    stopDurationTimer()
                    logger.info("🛑 Call monitoring ended")
                default:
                    break
                }
            }
        }
    }
    
    private func startDurationTimer() {
        stopDurationTimer()
        callDuration = 0
        logger.info("🕒 Timer initialized")
        
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.callDuration += 1
            }
        }
    }

    private func stopDurationTimer() {
        if durationTimer != nil {
            logger.info("🕒 Timer invalidated")
            durationTimer?.invalidate()
            durationTimer = nil
        }
    }

    deinit {
        // En deinit no podemos usar el logger si es un actor o singleton que ya se liberó
        print("🗑️ CallViewModel deinitialized")
        durationTimer?.invalidate()
        statusTask?.cancel()
    }
}
