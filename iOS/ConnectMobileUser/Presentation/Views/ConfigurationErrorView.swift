import SwiftUI

/// Error view displayed when AWS configuration is missing
struct ConfigurationErrorView: View {
    let errors: [String]
    
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
                
                // Error Icon
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                // Error Title
                Text("Configuration Error")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Error Message
                Text("The app is not properly configured. Please check the following:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Error List
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(errors, id: \.self) { error in
                        HStack(spacing: 10) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(red: 1.0, green: 0.95, blue: 0.95))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Instructions
                Text("Environment Setup Required")
                    .font(.headline)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set these environment variables in Xcode or Info.plist:")
                        .font(.caption)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• AWS_ACCESS_KEY_ID")
                        Text("• AWS_SECRET_ACCESS_KEY")
                        Text("• AWS_REGION")
                        Text("• CONNECT_INSTANCE_ID")
                        Text("• CONNECT_QUEUE_ID")
                        Text("• CONNECT_CONTACT_FLOW_ID")
                    }
                    .font(.caption2)
                    .monospaced()
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 1.0))
                .cornerRadius(8)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(20)
        }
    }
}

#Preview {
    ConfigurationErrorView(errors: [
        "AWS_ACCESS_KEY_ID not set",
        "CONNECT_INSTANCE_ID not set"
    ])
}
