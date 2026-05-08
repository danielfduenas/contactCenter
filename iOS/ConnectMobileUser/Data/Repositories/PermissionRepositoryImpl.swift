import Foundation
import AVFoundation
import UIKit

/// Implementation of PermissionRepository
class PermissionRepositoryImpl: PermissionRepository {
    private let logger = Logger.shared
    
    // MARK: - PermissionRepository Implementation
    
    func requestMicrophonePermission() async throws -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    self.logger.info("Microphone permission granted")
                } else {
                    self.logger.warning("Microphone permission denied")
                }
                continuation.resume(returning: granted)
            }
        }
    }
    
    func isMicrophonePermissionGranted() -> Bool {
        let status = AVAudioSession.sharedInstance().recordPermission
        let isGranted = (status == .granted)
        
        logger.info("Microphone permission status: \(isGranted ? "granted" : "denied/undetermined")")
        
        return isGranted
    }
    
    func openAppSettings() throws {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            throw CallError.unknown("Could not open app settings")
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(settingsURL)
        }
    }
}
