import Foundation

/// Utility for network reachability
enum NetworkReachability {
    static var isConnected: Bool {
        // Simple check - in production use Reachability library
        return true
    }
}
