import Foundation

/// Represents errors that can occur during call operations
enum CallError: Error, Equatable {
    case networkUnavailable
    case microphonePermissionDenied
    case authenticationFailed(String)
    case connectServiceUnavailable
    case timeout
    case contactNotFound
    case invalidParameters(String)
    case awsServiceError(String)
    case unknown(String)
    
    // MARK: - Computed Properties
    
    var displayText: String {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your network."
        case .microphonePermissionDenied:
            return "Microphone permission denied. Please enable it in Settings."
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .connectServiceUnavailable:
            return "Connect service unavailable. Please try again later."
        case .timeout:
            return "Request timed out. Please check your connection and try again."
        case .contactNotFound:
            return "Contact not found. The call may have ended."
        case .invalidParameters(let message):
            return "Invalid parameters: \(message)"
        case .awsServiceError(let message):
            return "AWS service error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .connectServiceUnavailable:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: CallError, rhs: CallError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable):
            return true
        case (.microphonePermissionDenied, .microphonePermissionDenied):
            return true
        case (.authenticationFailed(let lMsg), .authenticationFailed(let rMsg)):
            return lMsg == rMsg
        case (.connectServiceUnavailable, .connectServiceUnavailable):
            return true
        case (.timeout, .timeout):
            return true
        case (.contactNotFound, .contactNotFound):
            return true
        case (.invalidParameters(let lMsg), .invalidParameters(let rMsg)):
            return lMsg == rMsg
        case (.awsServiceError(let lMsg), .awsServiceError(let rMsg)):
            return lMsg == rMsg
        case (.unknown(let lMsg), .unknown(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}
