import SwiftUI

/// View with call control buttons
struct CallControlsView: View {
    @ObservedObject var viewModel: CallViewModel
    @State private var isMuted = false
    @State private var isOnSpeaker = true
    @State private var isOnHold = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Status indicators
            HStack(spacing: 16) {
                // Mute toggle
                ControlButton(
                    icon: isMuted ? "microphone.slash.fill" : "microphone.fill",
                    label: isMuted ? "Unmute" : "Mute",
                    isActive: isMuted,
                    action: { isMuted.toggle() }
                )
                
                // Speaker toggle
                ControlButton(
                    icon: isOnSpeaker ? "speaker.3.fill" : "speaker.slash.fill",
                    label: isOnSpeaker ? "Speaker" : "Earpiece",
                    isActive: isOnSpeaker,
                    action: { isOnSpeaker.toggle() }
                )
                
                // Hold toggle
                ControlButton(
                    icon: isOnHold ? "pause.fill" : "play.fill",
                    label: isOnHold ? "Resume" : "Hold",
                    isActive: isOnHold,
                    action: { isOnHold.toggle() }
                )
            }
            
            // End call button
            Button(action: {
                Task {
                    await viewModel.endCall()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 20))
                    
                    Text("End Call")
                        .font(.headline)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
    }
}

// MARK: - Control Button Component

struct ControlButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                
                Text(label)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                isActive ? Color.blue : Color(.systemGray5)
            )
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(12)
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
    
    return CallControlsView(viewModel: viewModel)
}
