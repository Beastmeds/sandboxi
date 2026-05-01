import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            TabView(selection: $selectedTab) {
                TerminalView()
                    .tag(0)
                FileManagerView()
                    .tag(1)
                CodeEditorView()
                    .tag(2)
                NetworkView()
                    .tag(3)
                SettingsView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom bottom tab bar
            HStack(spacing: 0) {
                ForEach(tabItems.indices, id: \.self) { i in
                    Button(action: { selectedTab = i }) {
                        VStack(spacing: 3) {
                            Image(systemName: tabItems[i].icon)
                                .font(.system(size: 16))
                                .foregroundColor(selectedTab == i ? Color(hex: "00ff41") : Color(hex: "333333"))
                            Text(tabItems[i].label)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(selectedTab == i ? Color(hex: "00ff41") : Color(hex: "333333"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                }
            }
            .background(Color(hex: "0a0a0a"))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(hex: "00ff41").opacity(0.3)),
                alignment: .top
            )
        }
    }

    private let tabItems: [(icon: String, label: String)] = [
        ("terminal", "terminal"),
        ("folder", "files"),
        ("doc.text", "editor"),
        ("network", "network"),
        ("gearshape", "settings")
    ]
}
