import Foundation

/// Use case for initiating a call to support
class InitiateCallUseCase {
    private let callRepository: CallRepository
    private let permissionRepository: PermissionRepository
    
    init(
        callRepository: CallRepository,
        permissionRepository: PermissionRepository
    ) {
        self.callRepository = callRepository
        self.permissionRepository = permissionRepository
    }
    
    /// Executes the call initiation flow
    /// - Parameters:
    ///   - instanceId: The Amazon Connect instance ID
    ///   - queueId: The target queue ID
    ///   - callerName: Optional caller name
    /// - Returns: The contact ID or throws an error
    func execute(
        instanceId: String,
        queueId: String,
        callerName: String? = nil
    ) async throws -> String {
        // Step 1: Validate network connectivity
        guard NetworkReachability.isConnected else {
            throw CallError.networkUnavailable
        }
        
        // Step 2: Request microphone permission
        let hasPermission = permissionRepository.isMicrophonePermissionGranted()
        if !hasPermission {
            let granted = try await permissionRepository.requestMicrophonePermission()
            guard granted else {
                throw CallError.microphonePermissionDenied
            }
        }
        
        // Step 3: Initiate the call
        let contactId = try await callRepository.initiateCall(
            instanceId: instanceId,
            queueId: queueId,
            callerName: callerName
        )
        
        return contactId
    }
}
