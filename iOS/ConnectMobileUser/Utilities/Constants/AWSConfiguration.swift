import Foundation

/// AWS Configuration holder
struct AWSConfiguration {
    static let shared = AWSConfiguration()
    
    // Load from environment variables, plist, or hardcode for testing
    let accessKeyId: String = ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"] ?? ""
    let secretAccessKey: String = ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"] ?? ""
    let sessionToken: String = ProcessInfo.processInfo.environment["AWS_SESSION_TOKEN"] ?? ""
    let region: String = ProcessInfo.processInfo.environment["AWS_REGION"] ?? "us-west-2"
    
    // Amazon Connect configuration
    let instanceId: String = ProcessInfo.processInfo.environment["CONNECT_INSTANCE_ID"] ?? ""
    let queueId: String = ProcessInfo.processInfo.environment["CONNECT_QUEUE_ID"] ?? ""
    let contactFlowId: String = ProcessInfo.processInfo.environment["CONNECT_CONTACT_FLOW_ID"] ?? ""
    
    private init() {}
}
