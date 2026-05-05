import SwiftUI

/// View with the call button for initiating calls
struct CallButtonView: View {
    @ObservedObject var viewModel: CallViewModel
    @Binding var callerName: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Caller name input
            VStack(alignment: .leading, spacing: 8) {
                Label("Your Name", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Enter your name", text: $callerName)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.words)
            }
            .padding(.horizontal, 4)
            
            // Main call button
            Button(action: {
                Task {
                    await viewModel.initiateCall(callerName: callerName.isEmpty ? nil : callerName)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Call Support")
                            .font(.headline)
                        Text("Connect with an agent")
                            .font(.caption)
                            .opacity(0.8)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, Color(red: 0, green: 0.3, blue: 1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .disabled(!viewModel.callState.displayText.contains("Ready"))
            
            // Info message
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How it works")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Tap the button to request support. You'll be connected to the next available agent.")
                            .font(.caption2)
                            .opacity(0.7)
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
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
    
    return CallButtonView(viewModel: viewModel, callerName: .constant(""))
}
