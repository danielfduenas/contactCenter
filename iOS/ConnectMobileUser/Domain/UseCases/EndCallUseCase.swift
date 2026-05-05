import Foundation

/// Use case for ending an active call
class EndCallUseCase {
    private let callRepository: CallRepository
    
    init(callRepository: CallRepository) {
        self.callRepository = callRepository
    }
    
    /// Executes the call ending flow
    /// - Parameter contactId: The contact ID to end
    /// - Returns: True if successful
    func execute(contactId: String) async throws -> Bool {
        return try await callRepository.endCall(contactId: contactId)
    }
}
