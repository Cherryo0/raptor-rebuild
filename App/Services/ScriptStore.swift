import Foundation

/// Local persistence for editor scripts under ~/Documents/RaptorUI.
/// Reads/writes local files only. Never executes scripts and never touches Roblox.
final class ScriptStore {
    static let welcomeScript = "-- Welcome to Raptor (clean-room rebuild)\n-- This editor never executes scripts against Roblox.\n-- Open a sample from Script Hub, or write your own.\nprint(\"Hello from the editor\")\n"
    static let helloScript = "-- hello.lua — harmless editor sample\n-- Prints to the local editor console only.\nprint(\"Hello, Raptor!\")\n"

    let baseDirectory: URL

    init(baseDirectory: URL? = nil) {
        if let baseDirectory {
            self.baseDirectory = baseDirectory
        } else {
            self.baseDirectory = FileManager.default
                .homeDirectoryForCurrentUser
                .appendingPathComponent("Documents/RaptorUI", isDirectory: true)
        }
    }

    var autoExecuteDirectory: URL { baseDirectory.appendingPathComponent("AutoExecute", isDirectory: true) }
    var dumpedDirectory: URL { baseDirectory.appendingPathComponent("Dumped", isDirectory: true) }

    func ensureDirectories() throws {
        try FileManager.default.createDirectory(at: autoExecuteDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: dumpedDirectory, withIntermediateDirectories: true)
    }

    func listScripts() throws -> [ScriptFile] {
        try ensureDirectories()
        let urls = try FileManager.default.contentsOfDirectory(
            at: baseDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles])
        return try urls.filter { $0.pathExtension == "lua" }.map { url in
            let content = try String(contentsOf: url, encoding: .utf8)
            let modified = (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date()
            return ScriptFile(name: url.lastPathComponent, content: content, url: url, modifiedAt: modified)
        }.sorted { $0.name < $1.name }
    }

    func listAutoExecuteScripts() throws -> [ScriptFile] {
        try ensureDirectories()
        let urls = try FileManager.default.contentsOfDirectory(at: autoExecuteDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        return try urls.filter { $0.pathExtension == "lua" }.map { url in
            ScriptFile(name: url.lastPathComponent, content: try String(contentsOf: url, encoding: .utf8), url: url)
        }.sorted { $0.name < $1.name }
    }

    func save(_ tab: ScriptTab) throws {
        try ensureDirectories()
        let url = tab.fileURL ?? baseDirectory.appendingPathComponent(tab.title)
        try tab.content.write(to: url, atomically: true, encoding: .utf8)
    }
}
