import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var callViewModel: CallViewModel?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Load AWS configuration
        let awsConfig = AWSConfiguration.shared
        
        // Initialize repositories and use cases
        let callRepository = CallRepositoryImpl()
        let permissionRepository = PermissionRepositoryImpl()
        
        let initiateCallUseCase = InitiateCallUseCase(
            callRepository: callRepository,
            permissionRepository: permissionRepository
        )
        let monitorCallStatusUseCase = MonitorCallStatusUseCase(callRepository: callRepository)
        let endCallUseCase = EndCallUseCase(callRepository: callRepository)
        
        // Create view model
        callViewModel = CallViewModel(
            instanceId: awsConfig.instanceId,
            queueId: awsConfig.queueId,
            contactFlowId: awsConfig.contactFlowId,
            initiateCallUseCase: initiateCallUseCase,
            monitorCallStatusUseCase: monitorCallStatusUseCase,
            endCallUseCase: endCallUseCase,
            permissionRepository: permissionRepository
        )
        
        // Create SwiftUI view hierarchy
        let contentView = ContentView(viewModel: callViewModel!)
        
        // Create window and set root view
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
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
