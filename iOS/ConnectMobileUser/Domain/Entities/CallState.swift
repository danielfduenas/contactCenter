import Foundation

/// Represents the different states a call can be in
enum CallState: Equatable {
    case idle
    case requestingPermission
    case connecting
    case ringing
    case active(duration: TimeInterval)
    case onHold
    case ending
    case ended(reason: DisconnectReason)
    case error(CallError)
    
    // MARK: - Computed Properties
    
    var isActive: Bool {
        switch self {
        case .active, .onHold:
            return true
        default:
            return false
        }
    }
    
    var isConnecting: Bool {
        switch self {
        case .connecting, .ringing, .requestingPermission:
            return true
        default:
            return false
        }
    }
    
    var displayText: String {
        switch self {
        case .idle:
            return "Ready to call"
        case .requestingPermission:
            return "Requesting microphone access..."
        case .connecting:
            return "Connecting to support..."
        case .ringing:
            return "Ringing..."
        case .active(let duration):
            return "In call • \(formatDuration(duration))"
        case .onHold:
            return "On hold"
        case .ending:
            return "Ending call..."
        case .ended(let reason):
            return "Call ended • \(reason.displayText)"
        case .error(let error):
            return "Error: \(error.displayText)"
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

enum DisconnectReason: String, Equatable {
    case userInitiated = "User ended call"
    case agentEnded = "Agent ended call"
    case timeout = "Call timed out"
    case noAgent = "No agent available"
    case networkError = "Network error"
    case unknown = "Unknown reason"
    
    var displayText: String {
        self.rawValue
    }
}
