import SwiftUI

/// Script Editor V1-style editor. Plain-text editing with line/character
/// counts. The Execute button is deliberately inert: it reports that live
/// execution is not implemented instead of pretending to run the script.
struct ScriptEditorView: View {
    @EnvironmentObject private var appState: AppState
    let tab: ScriptTab
    @State private var draft: String = ""
    @State private var executeMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tab.title).font(.headline)
                Spacer()
                Text("\(tab.lineCount) lines · \(tab.characterCount) chars")
                    .font(.caption).foregroundStyle(.secondary)
                Button("Save") { appState.saveActiveTab() }
                Button("Execute") {
                    executeMessage = InjectionBridgeStub.notImplementedReason
                }
                .help("Execute is not implemented in this clean-room rebuild.")
            }
            .padding(8)
            Divider()
            TextEditor(text: $draft)
                .font(.system(.body, design: .monospaced))
                .padding(4)
                .onAppear { draft = tab.content }
                .onChange(of: draft) { newValue in appState.updateActiveTabContent(newValue) }
                .onChange(of: tab.id) { _ in draft = tab.content }
            if let executeMessage {
                Text(executeMessage).font(.caption).foregroundStyle(.orange).padding(8)
            }
        }
    }
}
