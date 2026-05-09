import Foundation

/// AWS Configuration holder
/// 
/// This struct loads AWS credentials and Amazon Connect configuration from:
/// 1. Environment variables (highest priority)
/// 2. Info.plist
/// 3. Configuration files
///
/// AUTHENTICATION METHOD: IAM User (No Cognito)
/// - Uses permanent AWS IAM User credentials
/// - Access Key ID + Secret Access Key
/// - Required IAM permissions: connect:StartOutboundVoiceContact, etc.
///
/// For production, consider using:
/// - Temporary session credentials (with sessionToken)
/// - AWS Secrets Manager for rotation
/// - Keychain for secure storage
///
/// See: IAM_CONFIGURATION.md for detailed setup
struct AWSConfiguration {
    static let shared = AWSConfiguration()
    
    // MARK: - AWS IAM Credentials
    
    /// AWS Access Key ID (from IAM User)
    /// Load from: AWS_ACCESS_KEY_ID environment variable or Info.plist
    let accessKeyId: String = ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"] ?? ""
    
    /// AWS Secret Access Key (from IAM User)
    /// Load from: AWS_SECRET_ACCESS_KEY environment variable or Info.plist
    let secretAccessKey: String = ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"] ?? ""
    
    /// AWS Session Token (optional, for temporary credentials)
    /// Load from: AWS_SESSION_TOKEN environment variable or Info.plist
    /// Leave empty when using permanent IAM User credentials
    let sessionToken: String = ProcessInfo.processInfo.environment["AWS_SESSION_TOKEN"] ?? ""
    
    /// AWS Region (e.g., us-west-2, us-east-1)
    /// Load from: AWS_REGION environment variable or Info.plist
    let region: String = ProcessInfo.processInfo.environment["AWS_REGION"] ?? "us-west-2"
    
    // MARK: - Amazon Connect Configuration
    
    /// Amazon Connect Instance ID (UUID format)
    /// Example: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    let instanceId: String = ProcessInfo.processInfo.environment["CONNECT_INSTANCE_ID"] ?? ""
    
    /// Amazon Connect Queue ID (UUID format)
    /// This is the queue where inbound calls will be routed
    let queueId: String = ProcessInfo.processInfo.environment["CONNECT_QUEUE_ID"] ?? ""
    
    /// Amazon Connect Contact Flow ID (UUID format)
    /// This Contact Flow handles the outbound voice call logic
    /// IMPORTANT: Contact Flow must be in "PUBLISHED" state (not "Saved Draft")
    let contactFlowId: String = ProcessInfo.processInfo.environment["CONNECT_CONTACT_FLOW_ID"] ?? ""
    
    private init() {
        // Validate credentials on init
        #if DEBUG
        if accessKeyId.isEmpty {
            print("⚠️  AWS_ACCESS_KEY_ID not configured")
        }
        if secretAccessKey.isEmpty {
            print("⚠️  AWS_SECRET_ACCESS_KEY not configured")
        }
        if instanceId.isEmpty {
            print("⚠️  CONNECT_INSTANCE_ID not configured")
        }
        if queueId.isEmpty {
            print("⚠️  CONNECT_QUEUE_ID not configured")
        }
        if contactFlowId.isEmpty {
            print("⚠️  CONNECT_CONTACT_FLOW_ID not configured")
        }
        #endif
    }
    
    /// Check if configuration is complete and valid
    func isValid() -> Bool {
        return !accessKeyId.isEmpty &&
               !secretAccessKey.isEmpty &&
               !instanceId.isEmpty &&
               !queueId.isEmpty &&
               !contactFlowId.isEmpty
    }
    
    /// Get validation error message
    func validationErrors() -> [String] {
        var errors: [String] = []
        if accessKeyId.isEmpty { errors.append("AWS_ACCESS_KEY_ID not set") }
        if secretAccessKey.isEmpty { errors.append("AWS_SECRET_ACCESS_KEY not set") }
        if instanceId.isEmpty { errors.append("CONNECT_INSTANCE_ID not set") }
        if queueId.isEmpty { errors.append("CONNECT_QUEUE_ID not set") }
        if contactFlowId.isEmpty { errors.append("CONNECT_CONTACT_FLOW_ID not set") }
        return errors
    }
}
