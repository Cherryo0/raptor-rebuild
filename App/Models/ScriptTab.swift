import Foundation

/// One open editor tab (TABSYS in the original).
struct ScriptTab: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var content: String
    var isDirty: Bool
    var fileURL: URL?

    init(id: UUID = UUID(), title: String, content: String, isDirty: Bool = false, fileURL: URL? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.isDirty = isDirty
        self.fileURL = fileURL
    }

    var displayTitle: String { isDirty ? title + " •" : title }
    var lineCount: Int { content.components(separatedBy: "\n").count }
    var characterCount: Int { content.count }
}
