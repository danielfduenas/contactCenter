import Foundation

/// Protocol defining the contract for call operations
protocol CallRepository {
    /// Initiates an outbound call to the support queue
    /// - Parameters:
    ///   - instanceId: The Amazon Connect instance ID
    ///   - queueId: The target queue ID
    ///   - callerName: Optional caller name for display
    /// - Returns: The contact ID created by Amazon Connect
    func initiateCall(instanceId: String, queueId: String, callerName: String?) async throws -> String
    
    /// Monitors the status of an active call
    /// - Parameter contactId: The contact ID to monitor
    /// - Returns: An async stream of call state updates
    func monitorCallStatus(contactId: String) -> AsyncStream<CallState>
    
    /// Ends an active call
    /// - Parameter contactId: The contact ID to end
    /// - Returns: True if successful
    func endCall(contactId: String) async throws -> Bool
    
    /// Gets current call attributes from Amazon Connect
    /// - Parameter contactId: The contact ID
    /// - Returns: Call attributes dictionary
    func getCallAttributes(contactId: String) async throws -> [String: String]
    
    /// Updates call attributes in Amazon Connect
    /// - Parameters:
    ///   - contactId: The contact ID
    ///   - attributes: Dictionary of attributes to update
    func updateCallAttributes(contactId: String, attributes: [String: String]) async throws
}
