import Foundation

/// Use case for monitoring the status of an active call
class MonitorCallStatusUseCase {
    private let callRepository: CallRepository
    
    init(callRepository: CallRepository) {
        self.callRepository = callRepository
    }
    
    /// Executes the call status monitoring flow
    /// - Parameter contactId: The contact ID to monitor
    /// - Returns: An async stream of call state updates
    func execute(contactId: String) -> AsyncStream<CallState> {
        return callRepository.monitorCallStatus(contactId: contactId)
    }
}
