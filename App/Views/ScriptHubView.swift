import SwiftUI

/// Script Hub: bundled harmless samples. Tapping one opens it in a tab.
/// Samples are editor-only; they are never sent to Roblox.
struct HubScript: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let content: String
}

struct ScriptHubView: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""

    static let samples: [HubScript] = [
        HubScript(name: "hello.lua", description: "Harmless hello-world editor sample.", content: ScriptStore.helloScript),
        HubScript(name: "loop-demo.lua", description: "Local loop demo — editor only.", content: "-- loop-demo.lua (editor sample only)\nfor i = 1, 5 do\n  print(\"count: \" .. i)\nend\n"),
        HubScript(name: "table-demo.lua", description: "Local table demo — editor only.", content: "-- table-demo.lua (editor sample only)\nlocal t = { \"a\", \"b\", \"c\" }\nfor _, v in ipairs(t) do print(v) end\n"),
    ]

    var filtered: [HubScript] {
        query.isEmpty ? Self.samples : Self.samples.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.description.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Script Hub").font(.headline).padding(.horizontal, 8).padding(.top, 8)
            TextField("Search scripts…", text: $query).textFieldStyle(.roundedBorder).padding(.horizontal, 8)
            List(filtered) { script in
                Button {
                    appState.openTab(for: ScriptFile(name: script.name, content: script.content))
                } label: {
                    VStack(alignment: .leading) {
                        Text(script.name).font(.subheadline)
                        Text(script.description).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            Text("Samples are editor-only and never run against Roblox.")
                .font(.caption).foregroundStyle(.secondary).padding(8)
        }
    }
}
