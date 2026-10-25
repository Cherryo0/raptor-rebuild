import SwiftUI

/// Licence view: Sellix key entry + local device identifier (display only).
/// The key is held in memory for the session; live activation is a stub.
struct LicensingView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var key = ""
    @State private var message: String?

    var body: some View {
        Form {
            Section("Licence") {
                SecureField("Sellix key", text: $key)
                Text("Local device ID (display only, never uploaded): \(LicensingService.localDeviceIdentifier())")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Activate") {
                    Task {
                        do {
                            let state = try await LicensingService().activate(key: key)
                            appState.licenceState = state
                            message = "Activation result: \(String(describing: state))"
                        } catch {
                            message = error.localizedDescription
                        }
                    }
                }
                if let message { Text(message).font(.caption).foregroundStyle(.orange) }
            }
            Section("Status") {
                Text(String(describing: appState.licenceState)).font(.caption)
                Text("Live activation is not implemented in this clean-room stub. Keys are never put in a URL or logged.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 480, minHeight: 320)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
        }
    }
}
