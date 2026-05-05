import Foundation

/// Represents an active call
struct Call: Identifiable, Equatable {
    let id: String
    let contactId: String
    let status: CallState
    let startTime: Date?
    let endTime: Date?
    let agentName: String?
    let queueName: String?
    let customAttributes: [String: String]
    
    init(
        id: String = UUID().uuidString,
        contactId: String,
        status: CallState = .idle,
        startTime: Date? = nil,
        endTime: Date? = nil,
        agentName: String? = nil,
        queueName: String? = nil,
        customAttributes: [String: String] = [:]
    ) {
        self.id = id
        self.contactId = contactId
        self.status = status
        self.startTime = startTime
        self.endTime = endTime
        self.agentName = agentName
        self.queueName = queueName
        self.customAttributes = customAttributes
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        guard let startTime = startTime else { return 0 }
        let endTime = endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        status.isActive
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
