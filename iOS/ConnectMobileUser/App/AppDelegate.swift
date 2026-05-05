import UIKit
import AWSCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure AWS SDK
        configureAWS()
        
        return true
    }
    
    // MARK: UISceneDelegate Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - Private Methods
    
    private func configureAWS() {
        // Load AWS configuration from environment or config file
        let awsConfig = AWSConfiguration.shared
        
        // Initialize AWS SDK with credentials provider
        let credentialsProvider = AWSStaticCredentialsProvider(
            accessKey: awsConfig.accessKeyId,
            secretKey: awsConfig.secretAccessKey,
            sessionToken: awsConfig.sessionToken
        )
        
        let configuration = AWSServiceConfiguration(
            region: awsConfig.region,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}
