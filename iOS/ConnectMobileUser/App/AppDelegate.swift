import UIKit
import AWSCore
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("🎬 AppDelegate.application(_:didFinishLaunchingWithOptions:) called")
        do {
            try configureAWS()
            print("✅ AppDelegate: AWS configuration finished successfully")
        } catch {
            print("❌ AppDelegate: AWS configuration FAILED: \(error.localizedDescription)")
        }
        
        print("📱 AppDelegate: Setting up UI directly...")
        setupUI(application: application)
        
        print("✅ AppDelegate: returning true")
        return true
    }
    
    private func setupUI(application: UIApplication) {
        print("📱 [AppDelegate.setupUI] Creating window and scene...")
        
        // Load AWS configuration
        let awsConfig = AWSConfiguration.shared
        
        // Check if configuration is valid
        if !awsConfig.isValid() {
            print("⚠️  [AppDelegate.setupUI] Configuration is invalid")
            let errorView = ConfigurationErrorView(errors: awsConfig.validationErrors())
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = UIHostingController(rootView: errorView)
            self.window?.makeKeyAndVisible()
            return
        }
        
        print("📱 [AppDelegate.setupUI] Configuration is valid, initializing app...")
        
        // Initialize on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                print("📱 [AppDelegate.setupUI] Creating repositories...")
                let callRepository = CallRepositoryImpl()
                let permissionRepository = PermissionRepositoryImpl()
                
                print("📱 [AppDelegate.setupUI] Creating use cases...")
                let initiateCallUseCase = InitiateCallUseCase(
                    callRepository: callRepository,
                    permissionRepository: permissionRepository
                )
                let monitorCallStatusUseCase = MonitorCallStatusUseCase(callRepository: callRepository)
                let endCallUseCase = EndCallUseCase(callRepository: callRepository)
                
                print("📱 [AppDelegate.setupUI] Creating CallViewModel...")
                let viewModel = CallViewModel(
                    instanceId: awsConfig.instanceId,
                    queueId: awsConfig.queueId,
                    contactFlowId: awsConfig.contactFlowId,
                    initiateCallUseCase: initiateCallUseCase,
                    monitorCallStatusUseCase: monitorCallStatusUseCase,
                    endCallUseCase: endCallUseCase,
                    permissionRepository: permissionRepository
                )
                
                print("✅ [AppDelegate.setupUI] ViewModel created, updating UI...")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    print("✅ [AppDelegate.setupUI] Setting up window on main thread...")
                    let contentView = ContentView(viewModel: viewModel)
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.rootViewController = UIHostingController(rootView: contentView)
                    self?.window = window
                    window.makeKeyAndVisible()
                    print("✅ [AppDelegate.setupUI] UI is now visible!")
                    
                    // Request microphone permission after UI is visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("🎤 [AppDelegate] Requesting microphone permission on app launch...")
                        Task {
                            do {
                                let granted = try await permissionRepository.requestMicrophonePermission()
                                if granted {
                                    print("✅ [AppDelegate] Microphone permission granted!")
                                } else {
                                    print("⚠️  [AppDelegate] Microphone permission was denied")
                                }
                            } catch {
                                print("❌ [AppDelegate] Error requesting microphone permission: \(error)")
                            }
                        }
                    }
                }
            } catch {
                print("❌ [AppDelegate.setupUI] Error: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.window?.rootViewController?.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureAWS() throws {
        print("🚀 Iniciando configuración de AWS...")
        // Load AWS configuration from environment variables or config file
        let awsConfig = AWSConfiguration.shared
        print("✅ Configuración cargada: \(awsConfig.accessKeyId)")
        print("✅ Instance ID: \(awsConfig.instanceId)")
        print("✅ Queue ID: \(awsConfig.queueId)")
        print("✅ Contact Flow ID: \(awsConfig.contactFlowId)")
        
        // Validate config
        guard !awsConfig.accessKeyId.isEmpty else {
            throw NSError(domain: "AWS", code: 1, userInfo: [NSLocalizedDescriptionKey: "AWS_ACCESS_KEY_ID is empty"])
        }
        guard !awsConfig.secretAccessKey.isEmpty else {
            throw NSError(domain: "AWS", code: 2, userInfo: [NSLocalizedDescriptionKey: "AWS_SECRET_ACCESS_KEY is empty"])
        }
        guard !awsConfig.region.isEmpty else {
            throw NSError(domain: "AWS", code: 3, userInfo: [NSLocalizedDescriptionKey: "AWS_REGION is empty"])
        }
    
        // 1. Usar AWSStaticCredentialsProvider si usas solo AccessKey/SecretKey
        print("🔐 Creating AWS credentials provider...")
        let credentialsProvider = AWSStaticCredentialsProvider(
             accessKey: awsConfig.accessKeyId,
             secretKey: awsConfig.secretAccessKey
        )
        print("✅ Credentials provider created")
    
        // 2. Convert String to AWSRegionType
        print("🌍 Converting region string to AWSRegionType...")
        let regionType = awsConfig.region.aws_regionTypeValue()
        print("✅ regionType: \(regionType)")

        print("🔧 Creating AWSServiceConfiguration...")
        let configuration = AWSServiceConfiguration(
            region: regionType,
            credentialsProvider: credentialsProvider
        )
        print("✅ AWSServiceConfiguration created")
        
        print("📍 Setting default AWS service configuration...")
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        print("✅ AWS configuration complete - ready for Scene initialization")
    }
}
