import SwiftUI

/// TABSYS — the tab strip. New / select / close; dirty tabs show a dot.
struct TabBarView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(appState.tabs) { tab in
                    Button {
                        appState.activeTabID = tab.id
                    } label: {
                        HStack(spacing: 6) {
                            Text(tab.displayTitle)
                            Button { appState.closeTab(tab) } label: {
                                Image(systemName: "xmark").font(.caption2)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(appState.activeTabID == tab.id ? Color.accentColor.opacity(0.2) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
                Button { appState.newTab() } label: {
                    Image(systemName: "plus").padding(6)
                }
                .buttonStyle(.plain)
                .help("New tab")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}
