import SwiftUI

/// Entry point for the Raptor clean-room rebuild (macOS 13+, Swift 5.9).
/// No Roblox interaction is performed by this app; see InjectionBridge.
@main
struct RaptorApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Tab") { appState.newTab() }
                    .keyboardShortcut("t", modifiers: [.command])
                Button("Open Script…") { appState.openScriptFromDisk() }
                    .keyboardShortcut("o", modifiers: [.command])
                Button("Save") { appState.saveActiveTab() }
                    .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }
}
