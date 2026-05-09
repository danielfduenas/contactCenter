import Foundation
import AWSConnect
import AWSCore

/// Wrapper for AWS Connect SDK
class AWSConnectClient {
    static let shared = AWSConnectClient()
    
    private lazy var connectService: AWSConnect = {
        print("📱 [AWSConnectClient] Initializing AWSConnect service...")
        let service = AWSConnect.default()
        print("✅ [AWSConnectClient] AWSConnect service initialized")
        return service
    }()
    
    private let logger = Logger.shared
    
    init() {
        print("📱 [AWSConnectClient] Init called")
        // Initialize AWS SDK with proper logger
        AWSDDLog.sharedInstance.logLevel = .verbose
        if let ttyLogger = AWSDDTTYLogger.sharedInstance {
            AWSDDLog.add(ttyLogger)
        }
        print("✅ [AWSConnectClient] Logger initialized")
    }
    
    /// Initiates an outbound voice contact
    /// - Parameters:
    ///   - instanceId: The Amazon Connect instance ID
    ///   - contactFlowId: The ID of the contact flow to execute // NUEVO PARÁMETRO
    ///   - destinationPhoneNumber: The phone number or queue to route to
    ///   - sourcePhoneNumber: The caller's phone number
    ///   - queueId: Optional queue ID // NUEVO PARÁMETRO (Opcional pero recomendado)
    ///   - attributes: Additional contact attributes
    /// - Returns: The contact ID
    func startOutboundVoiceContact(
        instanceId: String,
        contactFlowId: String,
        destinationPhoneNumber: String,
        sourcePhoneNumber: String,
        queueId: String? = nil,
        attributes: [String: String]
    ) async throws -> String {
        print("📱 [AWSConnectClient] startOutboundVoiceContact called with instanceId: \(instanceId)")
        return try await withCheckedThrowingContinuation { continuation in
            let request = AWSConnectStartOutboundVoiceContactRequest()
            request?.instanceId = instanceId
            request?.contactFlowId = contactFlowId // Asignación directa y segura
            request?.destinationPhoneNumber = destinationPhoneNumber
            request?.sourcePhoneNumber = sourcePhoneNumber
            request?.attributes = attributes
            
            if let qId = queueId {
                request?.queueId = qId
            }
            
            self.connectService.startOutboundVoiceContact(request!) { response, error in
                if let error = error {
                    self.logger.error("Failed to start outbound voice contact: \(error.localizedDescription)")
                    continuation.resume(throwing: CallError.awsServiceError(error.localizedDescription))
                } else if let response = response, let contactId = response.contactId {
                    self.logger.info("Outbound voice contact started with contact ID: \(contactId)")
                    continuation.resume(returning: contactId)
                } else {
                    self.logger.error("No contact ID received from AWS")
                    continuation.resume(throwing: CallError.unknown("No contact ID returned"))
                }
            }
        }
    }
    
    /// Gets the current attributes of a contact
    /// - Parameters:
    ///   - instanceId: The Amazon Connect instance ID
    ///   - contactId: The contact ID
    /// - Returns: Dictionary of contact attributes
    func getContactAttributes(
        instanceId: String,
        contactId: String
    ) async throws -> [String: String] {
        return try await withCheckedThrowingContinuation { continuation in
            let request = AWSConnectGetContactAttributesRequest()
            request?.instanceId = instanceId
            request?.initialContactId = contactId
            
            self.connectService.getContactAttributes(request!) { response, error in
                if let error = error {
                    self.logger.error("Failed to get contact attributes: \(error.localizedDescription)")
                    continuation.resume(throwing: CallError.awsServiceError(error.localizedDescription))
                } else if let response = response, let attributes = response.attributes as? [String: String] {
                    self.logger.info("Contact attributes retrieved: \(attributes)")
                    continuation.resume(returning: attributes)
                } else {
                    continuation.resume(returning: [:])
                }
            }
        }
    }
    
    /// Updates contact attributes
    /// - Parameters:
    ///   - instanceId: The Amazon Connect instance ID
    ///   - contactId: The contact ID
    ///   - attributes: Attributes to update
    func updateContactAttributes(
        instanceId: String,
        contactId: String,
        attributes: [String: String]
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let request = AWSConnectUpdateContactAttributesRequest()
            request?.instanceId = instanceId
            request?.initialContactId = contactId
            request?.attributes = attributes
            
            self.connectService.updateContactAttributes(request!) { response, error in
                if let error = error {
                    self.logger.error("Failed to update contact attributes: \(error.localizedDescription)")
                    continuation.resume(throwing: CallError.awsServiceError(error.localizedDescription))
                } else {
                    self.logger.info("Contact attributes updated successfully")
                    continuation.resume()
                }
            }
        }
    }
}
