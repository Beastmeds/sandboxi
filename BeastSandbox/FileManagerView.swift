import SwiftUI

struct FileManagerView: View {
    @State private var cwd: String = "/sandbox"
    @State private var items: [String] = []
    @State private var selected: String? = nil
    @State private var showNewFileAlert = false
    @State private var showNewDirAlert = false
    @State private var newName: String = ""
    @State private var fs: [String: FSNode] = SandboxFS.initial()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("// files")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                    Spacer()
                    Text(cwd)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(hex: "00aaff"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "0a0a0a"))
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "00ff41").opacity(0.3)), alignment: .bottom)

                // Toolbar
                HStack(spacing: 8) {
                    Button(action: goUp) {
                        Label("up", systemImage: "arrow.up")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .fmButton()
                    Button(action: { showNewFileAlert = true }) {
                        Label("new file", systemImage: "doc.badge.plus")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .fmButton()
                    Button(action: { showNewDirAlert = true }) {
                        Label("new dir", systemImage: "folder.badge.plus")
                            .font(.system(size: 11, design: .monospaced))
                    }
                    .fmButton()
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "0d0d0d"))

                // File list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(items, id: \.self) { name in
                            let full = cwd + "/" + name
                            let isDir = fs[full]?.type == .directory
                            HStack(spacing: 10) {
                                Image(systemName: isDir ? "folder.fill" : "doc.text")
                                    .font(.system(size: 13))
                                    .foregroundColor(isDir ? Color(hex: "00aaff") : Color(hex: "00ff41"))
                                    .frame(width: 18)
                                Text(name + (isDir ? "/" : ""))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(isDir ? Color(hex: "00aaff") : Color(hex: "00ff41"))
                                Spacer()
                                if !isDir, let size = fs[full]?.size {
                                    Text("\(size)B")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(Color(hex: "333333"))
                                }
                                if isDir {
                                    Text("\(fs[full]?.children?.count ?? 0) items")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(Color(hex: "333333"))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(selected == full ? Color(hex: "001800") : Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isDir {
                                    cwd = full
                                    loadItems()
                                } else {
                                    selected = full
                                }
                            }
                            Divider().background(Color(hex: "111111"))
                        }
                    }
                }

                // Bottom actions
                if let sel = selected {
                    HStack(spacing: 8) {
                        Text(sel.split(separator: "/").last.map(String.init) ?? "")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "00aaff"))
                            .lineLimit(1)
                        Spacer()
                        Button("delete") {
                            let name = sel.split(separator: "/").last.map(String.init) ?? ""
                            fs.removeValue(forKey: sel)
                            fs[cwd]?.children?.removeAll { $0 == name }
                            selected = nil
                            loadItems()
                        }
                        .fmButton()
                        .foregroundColor(Color(hex: "ff4444"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(hex: "0d0d0d"))
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "222222")), alignment: .top)
                }
            }
        }
        .onAppear { loadItems() }
        .alert("new file", isPresented: $showNewFileAlert) {
            TextField("filename.txt", text: $newName)
                .autocapitalization(.none)
            Button("create") { createFile() }
            Button("cancel", role: .cancel) { newName = "" }
        }
        .alert("new folder", isPresented: $showNewDirAlert) {
            TextField("folder-name", text: $newName)
                .autocapitalization(.none)
            Button("create") { createDir() }
            Button("cancel", role: .cancel) { newName = "" }
        }
    }

    private func loadItems() {
        items = fs[cwd]?.children ?? []
    }

    private func goUp() {
        let parts = cwd.split(separator: "/")
        if parts.count > 1 {
            cwd = "/" + parts.dropLast().joined(separator: "/")
            loadItems()
        }
    }

    private func createFile() {
        let n = newName.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        let p = cwd + "/" + n
        fs[p] = FSNode(type: .file, children: nil, content: "", size: 0)
        fs[cwd]?.children?.append(n)
        newName = ""
        loadItems()
    }

    private func createDir() {
        let n = newName.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return }
        let p = cwd + "/" + n
        fs[p] = FSNode(type: .directory, children: [], content: nil, size: 0)
        fs[cwd]?.children?.append(n)
        newName = ""
        loadItems()
    }
}

extension Button {
    func fmButton() -> some View {
        self
            .font(.system(size: 11, design: .monospaced))
            .foregroundColor(Color(hex: "00ff41"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: "111111"))
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(hex: "222222"), lineWidth: 0.5))
            .cornerRadius(3)
    }
}
