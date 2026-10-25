import SwiftUI

/// Main window: tab bar on top, editor centre, hub/settings as side panels.
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingHub = false
    @State private var showingSettings = false
    @State private var showingLicensing = false

    var body: some View {
        VStack(spacing: 0) {
            TabBarView()
            Divider()
            HSplitView {
                if let tab = appState.activeTab {
                    ScriptEditorView(tab: tab)
                        .frame(minWidth: 500)
                } else {
                    Text("No tab open.").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                if showingHub {
                    ScriptHubView()
                        .frame(minWidth: 240, idealWidth: 280)
                }
            }
            Divider()
            HStack {
                Text(appState.statusMessage)
                Spacer()
                Text("Injection: not implemented (stub)")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Script Hub") { showingHub.toggle() }
                Button("Settings") { showingSettings.toggle() }
                Button("Licence") { showingLicensing.toggle() }
            }
        }
        .sheet(isPresented: $showingSettings) { SettingsView().environmentObject(appState) }
        .sheet(isPresented: $showingLicensing) { LicensingView().environmentObject(appState) }
    }
}
