import SwiftUI
import Combine

/// Main view model for managing call state and operations
@MainActor
class CallViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var callState: CallState = .idle
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
    private var statusStream: AsyncStream<CallState>? = nil
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
    }
    
    // MARK: - Public Methods
    
    func initiateCall(callerName: String? = nil) async {
        callState = .requestingPermission
        logger.info("Starting call initiation process")
        
        do {
            // Step 1: Check and request permissions
            let hasPermission = permissionRepository.isMicrophonePermissionGranted()
            if !hasPermission {
                let granted = try await permissionRepository.requestMicrophonePermission()
                if !granted {
                    callState = .error(.microphonePermissionDenied)
                    errorMessage = CallError.microphonePermissionDenied.displayText
                    showErrorAlert = true
                    logger.error("Microphone permission denied")
                    return
                }
            }
            
            // Step 2: Initiate the call
            callState = .connecting
            let contactId = try await initiateCallUseCase.execute(
                instanceId: instanceId,
                queueId: queueId,
                callerName: callerName
            )
            
            logger.info("Call initiated successfully. Contact ID: \(contactId)")
            
            // Step 3: Create call object and start monitoring
            currentCall = Call(contactId: contactId, status: .connecting)
            monitorCallStatus(contactId: contactId)
            
        } catch let error as CallError {
            callState = .error(error)
            errorMessage = error.displayText
            showErrorAlert = true
            logger.error("Call initiation failed: \(error.displayText)")
        } catch {
            let callError = CallError.unknown(error.localizedDescription)
            callState = .error(callError)
            errorMessage = callError.displayText
            showErrorAlert = true
            logger.error("Unexpected error during call initiation: \(error)")
        }
    }
    
    func endCall() async {
        guard let contactId = currentCall?.contactId else {
            logger.warning("No active call to end")
            return
        }
        
        callState = .ending
        
        do {
            let success = try await endCallUseCase.execute(contactId: contactId)
            if success {
                callState = .ended(reason: .userInitiated)
                stopDurationTimer()
                logger.info("Call ended successfully")
            } else {
                logger.warning("Call end returned false")
            }
        } catch let error as CallError {
            callState = .error(error)
            errorMessage = error.displayText
            showErrorAlert = true
            logger.error("Error ending call: \(error.displayText)")
        } catch {
            let callError = CallError.unknown(error.localizedDescription)
            callState = .error(callError)
            errorMessage = callError.displayText
            showErrorAlert = true
            logger.error("Unexpected error ending call: \(error)")
        }
    }
    
    func dismissError() {
        errorMessage = nil
        showErrorAlert = false
        
        // Reset to idle if error occurred before connection
        if case .error = callState {
            callState = .idle
            currentCall = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func monitorCallStatus(contactId: String) {
        statusTask = Task {
            for await status in monitorCallStatusUseCase.execute(contactId: contactId) {
                // Update call state
                callState = status
                
                // Handle state transitions
                switch status {
                case .active:
                    startDurationTimer()
                    logger.info("Call is now active")
                case .ended, .error:
                    stopDurationTimer()
                    logger.info("Call monitoring ended")
                default:
                    break
                }
            }
        }
    }
    
    private func startDurationTimer() {
        stopDurationTimer()
        callDuration = 0
        
        // El closure del Timer es 'Sendable' en Swift 6
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Usamos Task para saltar explícitamente al MainActor de forma segura
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.callDuration += 1
            }
        }
    }

    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }

    deinit {
        // Aquí invalidamos directamente el timer sin llamar al método aislado
        durationTimer?.invalidate()
        // Para el task, no necesitas llamar a un método del actor
        statusTask?.cancel()
    }
}
