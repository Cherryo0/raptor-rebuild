import SwiftUI

/// Settings: stored preferences only. Toggles here have no effect on Roblox;
/// they mirror the original's claimed options (sandbox, FPS, presence, …)
/// as local configuration, documented in docs/modules/12-settings-sandbox.md.
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Editor") {
                Toggle("Auto Execute (list only — never runs scripts)", isOn: $appState.settings.autoExecuteEnabled)
                Toggle("Error protection (editor validation)", isOn: $appState.settings.errorProtection)
            }
            Section("Sandbox") {
                Toggle("Sandbox enabled", isOn: $appState.settings.sandboxEnabled)
                Toggle("Unlimited FPS (stored preference only)", isOn: $appState.settings.unlimitedFPS)
            }
            Section("Presence") {
                Toggle("Discord presence (local toggle only — no Discord calls)", isOn: $appState.settings.discordPresenceEnabled)
            }
            Section("Injection — intentionally unavailable") {
                Toggle("Auto Inject", isOn: $appState.settings.autoInjectEnabled).disabled(true)
                Toggle("Allow server teleports / bypass place restrictions", isOn: $appState.settings.allowServerTeleports).disabled(true)
                Text("These options are disabled: live injection, teleports and bypasses are out of scope for this rebuild.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Scripts directory") {
                Text("~/Documents/\(appState.settings.scriptsDirectoryName)")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 480, minHeight: 420)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
        }
    }
}
