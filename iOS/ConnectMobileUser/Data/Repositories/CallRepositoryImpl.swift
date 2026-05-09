import Foundation
import Combine

/// Implementation of CallRepository using AWS Connect SDK
class CallRepositoryImpl: CallRepository {
    private let awsClient: AWSConnectClient
    private let logger = Logger.shared
    private nonisolated let pollingTaskLock = NSLock()
    private var statusPollingTasks: [String: Task<Void, Never>] = [:]
    private var statusContinuations: [String: AsyncStream<CallState>.Continuation] = [:]
    
    init(awsClient: AWSConnectClient = .shared) {
        self.awsClient = awsClient
    }
    
    // MARK: - CallRepository Implementation
    
    func initiateCall(
        instanceId: String,
        queueId: String,
        callerName: String?
    ) async throws -> String {
        
        // 1. Traemos tu configuración para sacar el ContactFlowId
        let config = AWSConfiguration.shared
        
        let attributes: [String: String] = [
            "QueueId": queueId,
            "Source": "MobileApp",
            "CallerName": callerName ?? "Mobile User"
        ]
        
        // 2. Llamamos al cliente con la nueva estructura completa
        let contactId = try await awsClient.startOutboundVoiceContact(
            instanceId: instanceId,
            contactFlowId: config.contactFlowId,
            destinationPhoneNumber: "+12816525076",
            sourcePhoneNumber: "+14128300856",
            queueId: queueId, // Le pasamos el parámetro opcional que agregamos
            attributes: attributes
        )
        
        logger.info("Call initiated with contact ID: \(contactId)")
        return contactId
    }
    
    func monitorCallStatus(contactId: String) -> AsyncStream<CallState> {
        return AsyncStream { continuation in
            self.statusContinuations[contactId] = continuation
            
            let task = Task {
                var pollInterval: TimeInterval = 1.0
                let maxInterval: TimeInterval = 5.0
                
                while !Task.isCancelled {
                    do {
                        // Simulate getting call status
                        // In production, this would query AWS Connect API
                        let status = try await self.fetchCallStatus(contactId: contactId)
                        
                        // Emit status update
                        continuation.yield(status)
                        
                        // Check if call is connected or ended
                        switch status {
                        case .active:
                            pollInterval = 2.0
                        case .ended:
                            continuation.finish()
                            return
                        default:
                            break
                        }
                        
                        // Exponential backoff for polling
                        try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
                        if pollInterval < maxInterval {
                            pollInterval += 1.0
                        }
                        
                    } catch {
                        self.logger.error("Error monitoring call status: \(error)")
                        continuation.yield(.error(.awsServiceError(error.localizedDescription)))
                        
                        // Retry with backoff
                        try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
                    }
                }
                
                continuation.finish()
            }
            
            self.pollingTaskLock.withLock {
                self.statusPollingTasks[contactId] = task
            }
            
            continuation.onTermination = { @Sendable [weak self] _ in
                guard let self = self else { return }
                self.pollingTaskLock.withLock {
                    self.statusPollingTasks[contactId]?.cancel()
                    self.statusPollingTasks.removeValue(forKey: contactId)
                }
                DispatchQueue.main.async {
                    self.statusContinuations.removeValue(forKey: contactId)
                }
            }
        }
    }
    
    func endCall(contactId: String) async throws -> Bool {
        // Cancel the polling task
        pollingTaskLock.withLock {
            statusPollingTasks[contactId]?.cancel()
            statusPollingTasks.removeValue(forKey: contactId)
        }
        
        // Finish the stream
        statusContinuations[contactId]?.finish()
        statusContinuations.removeValue(forKey: contactId)
        
        logger.info("Call ended for contact ID: \(contactId)")
        return true
    }
    
    func getCallAttributes(contactId: String) async throws -> [String: String] {
        // This would be implemented in production
        // For now, return empty dictionary
        return [:]
    }
    
    func updateCallAttributes(
        contactId: String,
        attributes: [String: String]
    ) async throws {
        logger.info("Updating call attributes for contact ID: \(contactId)")
        // This would be implemented in production
    }
    
    // MARK: - Private Methods
    
    private func fetchCallStatus(contactId: String) async throws -> CallState {
        // Placeholder implementation
        // In production, query AWS Connect API for actual status
        // For now, simulate a connection sequence
        
        // This would be replaced with actual AWS API calls
        return .connecting
    }
}
