import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var callViewModel: CallViewModel?
    
    override init() {
        super.init()
        print("🟣 SceneDelegate.init() called - SceneDelegate is being initialized")
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("🟣 SceneDelegate.scene(_:willConnectTo:options:) called - THIS IS THE SCENE DELEGATE CALLBACK")
        
        guard let windowScene = (scene as? UIWindowScene) else {
            print("❌ SceneDelegate: scene is not a UIWindowScene")
            return
        }
        
        print("🟣 [SceneDelegate] Got UIWindowScene")
        
        // Load AWS configuration
        let awsConfig = AWSConfiguration.shared
        print("🟣 [SceneDelegate] AWSConfiguration loaded")
        
        // Check if configuration is valid
        if !awsConfig.isValid() {
            print("⚠️  [SceneDelegate] Configuration is invalid, showing error view")
            // Show configuration error view
            let errorView = ConfigurationErrorView(errors: awsConfig.validationErrors())
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: errorView)
            self.window = window
            window.makeKeyAndVisible()
            return
        }
        
        print("🟣 [SceneDelegate] Configuration is valid, initializing repositories...")
        
        // Initialize repositories and use cases on background thread to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                print("📱 [SceneDelegate] Creating CallRepositoryImpl...")
                let callRepository = CallRepositoryImpl()
                print("✅ [SceneDelegate] CallRepositoryImpl created")
                
                print("📱 [SceneDelegate] Creating PermissionRepositoryImpl...")
                let permissionRepository = PermissionRepositoryImpl()
                print("✅ [SceneDelegate] PermissionRepositoryImpl created")
                
                print("📱 [SceneDelegate] Creating InitiateCallUseCase...")
                let initiateCallUseCase = InitiateCallUseCase(
                    callRepository: callRepository,
                    permissionRepository: permissionRepository
                )
                print("✅ [SceneDelegate] InitiateCallUseCase created")
                
                print("📱 [SceneDelegate] Creating MonitorCallStatusUseCase...")
                let monitorCallStatusUseCase = MonitorCallStatusUseCase(callRepository: callRepository)
                print("✅ [SceneDelegate] MonitorCallStatusUseCase created")
                
                print("📱 [SceneDelegate] Creating EndCallUseCase...")
                let endCallUseCase = EndCallUseCase(callRepository: callRepository)
                print("✅ [SceneDelegate] EndCallUseCase created")
                
                print("📱 [SceneDelegate] Creating CallViewModel...")
                let viewModel = CallViewModel(
                    instanceId: awsConfig.instanceId,
                    queueId: awsConfig.queueId,
                    contactFlowId: awsConfig.contactFlowId,
                    initiateCallUseCase: initiateCallUseCase,
                    monitorCallStatusUseCase: monitorCallStatusUseCase,
                    endCallUseCase: endCallUseCase,
                    permissionRepository: permissionRepository
                )
                print("✅ [SceneDelegate] CallViewModel created")
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    print("📱 [SceneDelegate] Setting up UI on main thread...")
                    self?.callViewModel = viewModel
                    let contentView = ContentView(viewModel: viewModel)
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = UIHostingController(rootView: contentView)
                    self?.window = window
                    window.makeKeyAndVisible()
                    print("✅ [SceneDelegate] UI setup complete")
                }
            } catch {
                print("❌ [SceneDelegate] Error during initialization: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Initialization Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.window?.rootViewController?.present(alert, animated: true)
                }
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Release resources when scene disconnects
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume any paused or deferenced tasks
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Pause ongoing operations
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo changes from sceneDidEnterBackground
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save changes and release resources
    }
}
