import SwiftUI

/// View displaying the current call status
struct CallStatusView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 120, height: 120)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }
            
            // Status Text
            Text(viewModel.callState.displayText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Duration (if call is active)
            if case .active = viewModel.callState {
                Text(formatDuration(viewModel.callDuration))
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .monospaced()
            }
            
            // Agent info (if available)
            if let agentName = viewModel.currentCall?.agentName {
                VStack(spacing: 4) {
                    Text("Connected with")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(agentName)
                        .font(.body)
                        .fontWeight(.medium)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch viewModel.callState {
        case .idle:
            return .blue
        case .connecting, .ringing, .requestingPermission:
            return .orange
        case .active:
            return .green
        case .onHold:
            return .yellow
        case .ending:
            return .orange
        case .ended:
            return .gray
        case .error:
            return .red
        }
    }
    
    private var statusIcon: String {
        switch viewModel.callState {
        case .idle:
            return "phone"
        case .connecting, .requestingPermission:
            return "hourglass"
        case .ringing:
            return "bell.fill"
        case .active:
            return "phone.fill"
        case .onHold:
            return "pause.circle"
        case .ending:
            return "xmark.circle"
        case .ended:
            return "checkmark.circle"
        case .error:
            return "xmark.circle.fill"
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
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
    
    return CallStatusView(viewModel: viewModel)
}
