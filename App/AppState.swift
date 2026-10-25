import Foundation
import SwiftUI

/// Single source of truth for the app. All mutation happens on the main actor.
@MainActor
final class AppState: ObservableObject {
    @Published var tabs: [ScriptTab] = []
    @Published var activeTabID: UUID?
    @Published var settings = AppSettings()
    @Published var licenceState: LicenceState = .unknown
    @Published var statusMessage: String = "Ready."

    private let store = ScriptStore()

    init() {
        let welcome = ScriptTab(title: "Welcome.lua", content: ScriptStore.welcomeScript)
        tabs = [welcome]
        activeTabID = welcome.id
    }

    var activeTab: ScriptTab? {
        get { tabs.first { $0.id == activeTabID } }
        set { if let tab = newValue { activeTabID = tab.id } }
    }

    func newTab() {
        let tab = ScriptTab(title: "Untitled \(tabs.count + 1).lua", content: "-- New script\n")
        tabs.append(tab)
        activeTabID = tab.id
    }

    func closeTab(_ tab: ScriptTab) {
        tabs.removeAll { $0.id == tab.id }
        if activeTabID == tab.id { activeTabID = tabs.last?.id }
        if tabs.isEmpty { newTab() }
    }

    func updateActiveTabContent(_ content: String) {
        guard let index = tabs.firstIndex(where: { $0.id == activeTabID }) else { return }
        tabs[index].content = content
        tabs[index].isDirty = true
    }

    func saveActiveTab() {
        guard let tab = activeTab else { return }
        do {
            try store.save(tab)
            if let index = tabs.firstIndex(where: { $0.id == tab.id }) { tabs[index].isDirty = false }
            statusMessage = "Saved \(tab.title)."
        } catch {
            statusMessage = "Save failed: \(error.localizedDescription)"
        }
    }

    func openScriptFromDisk() {
        // File-picker integration is an open question (see docs/modules/06-script-editor.md).
        // This skeleton loads the first bundled sample instead of presenting a panel.
        statusMessage = "Open-from-disk uses the system file picker in the full build; loading a sample for now."
        let sample = ScriptFile(name: "hello.lua", content: ScriptStore.helloScript)
        let tab = ScriptTab(title: sample.name, content: sample.content)
        tabs.append(tab)
        activeTabID = tab.id
    }

    func openTab(for file: ScriptFile) {
        if let existing = tabs.first(where: { $0.title == file.name }) {
            activeTabID = existing.id
            return
        }
        let tab = ScriptTab(title: file.name, content: file.content)
        tabs.append(tab)
        activeTabID = tab.id
    }
}

/// Persisted user preferences. Stored via UserDefaults in the full build.
struct AppSettings: Codable, Equatable {
    var autoExecuteEnabled: Bool = false
    var unlimitedFPS: Bool = false
    var sandboxEnabled: Bool = true
    var errorProtection: Bool = true
    var discordPresenceEnabled: Bool = false
    var allowServerTeleports: Bool = false
    var autoInjectEnabled: Bool = false
    var scriptsDirectoryName: String = "RaptorUI"
}

enum LicenceState: Equatable {
    case unknown
    case checking
    case active(expires: Date?)
    case inactive(reason: String)
    case notImplemented
}
