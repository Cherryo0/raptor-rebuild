import Foundation

/// A script file on disk (local editor only — never executed against Roblox).
struct ScriptFile: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var content: String
    var url: URL?
    var modifiedAt: Date

    init(id: UUID = UUID(), name: String, content: String, url: URL? = nil, modifiedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.content = content
        self.url = url
        self.modifiedAt = modifiedAt
    }

    var isAutoExecuteCandidate: Bool {
        url?.path.contains("AutoExecute") == true
    }
}
