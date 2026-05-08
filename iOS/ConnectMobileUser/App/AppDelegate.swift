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
        // Load AWS configuration from environment variables or config file
        let awsConfig = AWSConfiguration.shared
        
        // IAM User Authentication (No Cognito)
        // This approach uses direct AWS IAM credentials (Access Key ID + Secret Access Key)
        // to authenticate with Amazon Connect API.
        //
        // IMPORTANT: For production, consider using:
        // 1. Temporary session credentials instead of permanent keys
        // 2. AWS Secrets Manager for credential rotation
        // 3. Keychain storage for sensitive data
        //
        // See: IAM_CONFIGURATION.md for detailed setup instructions
    
        // 1. Usar AWSStaticCredentialsProvider si usas solo AccessKey/SecretKey
        // O AWSBasicSessionCredentialsProvider si realmente tienes un SessionToken
        let credentialsProvider = AWSStaticCredentialsProvider(
             accessKey: awsConfig.accessKeyId,
             secretKey: awsConfig.secretAccessKey
        )
    
        // 2. CORRECCIÓN DEL ERROR: Convertir String a AWSRegionType de forma segura
        // awsConfig.region debe ser algo como "us-east-1"
        let regionType = awsConfig.region.aws_regionTypeValue() 
    
        // Si la extensión anterior no te aparece, usa el mapeo manual que es infalible:
        // let regionType = AWSRegionType.USEast1 

        let configuration = AWSServiceConfiguration(
            region: regionType,
            credentialsProvider: credentialsProvider
    )
    
    AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}
