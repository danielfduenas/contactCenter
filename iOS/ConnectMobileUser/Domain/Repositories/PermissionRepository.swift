import Foundation

/// Protocol defining the contract for permission operations
protocol PermissionRepository {
    /// Requests microphone permission from the user
    /// - Returns: True if permission was granted
    func requestMicrophonePermission() async throws -> Bool
    
    /// Checks if microphone permission is currently granted
    /// - Returns: True if permission is granted
    func isMicrophonePermissionGranted() -> Bool
    
    /// Opens app settings for the user to manage permissions
    func openAppSettings() throws
}
