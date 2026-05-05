import SwiftUI

/// Main content view for the call interface
struct ContentView: View {
    @StateObject private var viewModel: CallViewModel
    @State private var callerName: String = ""
    
    init(viewModel: CallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.90, green: 0.90, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Status Card
                CallStatusView(viewModel: viewModel)
                
                Spacer()
                
                // Call Control Buttons
                if viewModel.callState == .idle {
                    CallButtonView(viewModel: viewModel, callerName: $callerName)
                } else {
                    CallControlsView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .padding(20)
        }
        .alert("Call Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            if let message = viewModel.errorMessage {
                Text(message)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let callRepository = CallRepositoryImpl()
    let permissionRepository = PermissionRepositoryImpl()
    
    let initiateCallUseCase = InitiateCallUseCase(
        callRepository: callRepository,
        permissionRepository: permissionRepository
    )
    let monitorCallStatusUseCase = MonitorCallStatusUseCase(callRepository: callRepository)
    let endCallUseCase = EndCallUseCase(callRepository: callRepository)
    
    let viewModel = CallViewModel(
        instanceId: "test-instance-id",
        queueId: "test-queue-id",
        contactFlowId: "test-flow-id",
        initiateCallUseCase: initiateCallUseCase,
        monitorCallStatusUseCase: monitorCallStatusUseCase,
        endCallUseCase: endCallUseCase,
        permissionRepository: permissionRepository
    )
    
    return ContentView(viewModel: viewModel)
}
