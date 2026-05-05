import Foundation
import os

/// Centralized logging utility
class Logger {
    static let shared = Logger()
    
    private let osLogger = os.Logger(subsystem: "com.connectcenter.mobile.user", category: "general")
    
    func info(_ message: String) {
        osLogger.info("\(message)")
    }
    
    func warning(_ message: String) {
        osLogger.warning("\(message)")
    }
    
    func error(_ message: String) {
        osLogger.error("\(message)")
    }
    
    func debug(_ message: String) {
        osLogger.debug("\(message)")
    }
}
