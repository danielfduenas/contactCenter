import Foundation
import AVFoundation
import UIKit

class PermissionRepositoryImpl: PermissionRepository {
    private let logger = Logger.shared
    
    func requestMicrophonePermission() async throws -> Bool {
        // 1. Verificación inicial de estado
        if isMicrophonePermissionGranted() { 
            logger.info("✅ Microphone permission already granted")
            return true 
        }
        
        logger.info("🎤 Requesting microphone permission...")
        
        // 2. Setup audio session first
        do {
            try setupAudioSession()
        } catch {
            logger.error("❌ Failed to setup audio session: \(error)")
            throw error
        }
        
        // 3. Si no sabemos (undetermined), pedimos
        // IMPORTANT: requestRecordPermission MUST be called from main thread
        return await withCheckedContinuation { [weak self] continuation in
            DispatchQueue.main.async {
                self?.logger.info("🎤 Calling requestRecordPermission on main thread...")
                
                // Use AVAudioSession.requestRecordPermission (works on all iOS versions)
                AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                    self?.logPermissionResult(granted)
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func isMicrophonePermissionGranted() -> Bool {
        // Use AVAudioSession for all iOS versions (most compatible)
        let status = AVAudioSession.sharedInstance().recordPermission
        let isGranted = (status == .granted)
        
        logger.info("🎤 Microphone permission status: \(isGranted ? "granted" : "denied/undetermined")")
        return isGranted
    }

    // MARK: - Private Helpers
    
    private func setupAudioSession() throws {
        logger.info("🎧 Setting up audio session...")
        let session = AVAudioSession.sharedInstance()
        
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        
        logger.info("✅ Audio session configured successfully")
    }
    
    private func logPermissionResult(_ granted: Bool) {
        if granted {
            self.logger.info("✅ Microphone permission granted")
        } else {
            self.logger.warning("❌ Microphone permission denied")
        }
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



