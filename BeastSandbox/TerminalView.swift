import SwiftUI

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let type: LineType
    enum LineType { case normal, error, warn, info, system, dim }
}

struct TerminalView: View {
    @State private var lines: [TerminalLine] = []
    @State private var input: String = ""
    @State private var history: [String] = []
    @State private var histIdx: Int = -1
    @State private var cwd: String = "/sandbox"
    @FocusState private var inputFocused: Bool

    // Virtual filesystem
    @State private var fs: [String: FSNode] = SandboxFS.initial()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("// terminal")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                    Spacer()
                    Text(cwd)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(hex: "006622"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "0a0a0a"))
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "00ff41").opacity(0.3)), alignment: .bottom)

                // Output
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(lines) { line in
                                Text(line.text)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(lineColor(line.type))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(line.id)
                            }
                        }
                        .padding(10)
                    }
                    .onChange(of: lines.count) { _ in
                        if let last = lines.last { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }

                // Input row
                HStack(spacing: 4) {
                    Text("sandbox@beast:~$")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                    TextField("", text: $input)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                        .accentColor(Color(hex: "00ff41"))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($inputFocused)
                        .onSubmit { runCommand() }
                        .submitLabel(.go)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(hex: "000000"))
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "111111")), alignment: .top)
            }
        }
        .onAppear {
            boot()
            inputFocused = true
        }
    }

    private func lineColor(_ t: TerminalLine.LineType) -> Color {
        switch t {
        case .normal: return Color(hex: "00ff41")
        case .error:  return Color(hex: "ff4444")
        case .warn:   return Color(hex: "ffaa00")
        case .info:   return Color(hex: "00aaff")
        case .system: return Color(hex: "aa00ff")
        case .dim:    return Color(hex: "006622")
        }
    }

    private func print(_ text: String, _ type: TerminalLine.LineType = .normal) {
        lines.append(TerminalLine(text: text, type: type))
    }

    private func boot() {
        print("BeastSandbox OS v1.0", .system)
        print("type \"help\" for commands", .dim)
        print("----------------------------------------", .dim)
    }

    private func runCommand() {
        let raw = input.trimmingCharacters(in: .whitespaces)
        guard !raw.isEmpty else { return }
        history.insert(raw, at: 0)
        histIdx = -1
        print("sandbox@beast:~$ \(raw)", .dim)
        input = ""

        let parts = raw.split(separator: " ", maxSplits: 10).map(String.init)
        let cmd = parts[0]
        let args = Array(parts.dropFirst())

        switch cmd {
        case "help":
            let cmds = ["help","clear","ls [dir]","pwd","cd <dir>","cat <file>","mkdir <name>","touch <name>","rm <name>","echo <text>","whoami","date","env","ps","status"]
            print("available commands:", .info)
            cmds.forEach { print("  \($0)") }
        case "clear":
            lines = []
        case "pwd":
            print(cwd)
        case "ls":
            let path = args.first ?? cwd
            let resolved = resolve(path)
            if let node = fs[resolved], node.type == .directory {
                (node.children ?? []).forEach { child in
                    let full = resolved + "/" + child
                    let isDir = fs[full]?.type == .directory
                    print("  " + child + (isDir ? "/" : ""))
                }
            } else {
                print("ls: no such directory: \(path)", .error)
            }
        case "cd":
            let target = args.first ?? "/sandbox"
            let resolved = target == "~" ? "/sandbox" : resolve(target)
            if target == ".." {
                let parts2 = cwd.split(separator: "/")
                cwd = parts2.count > 1 ? "/" + parts2.dropLast().joined(separator: "/") : "/sandbox"
                print("→ \(cwd)", .dim)
            } else if fs[resolved]?.type == .directory {
                cwd = resolved
                print("→ \(cwd)", .dim)
            } else {
                print("cd: not a directory: \(target)", .error)
            }
        case "cat":
            guard let name = args.first else { print("cat: missing filename", .error); return }
            let p = resolve(name)
            if let node = fs[p], node.type == .file {
                (node.content ?? "").split(separator: "\n", omittingEmptySubsequences: false).forEach { print(String($0)) }
            } else {
                print("cat: no such file: \(name)", .error)
            }
        case "mkdir":
            guard let name = args.first else { print("mkdir: missing name", .error); return }
            let p = cwd + "/" + name
            if fs[p] != nil { print("mkdir: already exists", .error); return }
            fs[p] = FSNode(type: .directory, children: [], content: nil, size: 0)
            fs[cwd]?.children?.append(name)
            print("created \(name)/")
        case "touch":
            guard let name = args.first else { print("touch: missing name", .error); return }
            let p = cwd + "/" + name
            if fs[p] == nil {
                fs[p] = FSNode(type: .file, children: nil, content: "", size: 0)
                fs[cwd]?.children?.append(name)
            }
            print("touched \(name)")
        case "rm":
            guard let name = args.first else { print("rm: missing name", .error); return }
            let p = resolve(name)
            if fs[p] == nil { print("rm: no such file: \(name)", .error); return }
            fs.removeValue(forKey: p)
            fs[cwd]?.children?.removeAll { $0 == name }
            print("removed \(name)", .warn)
        case "echo":
            print(args.joined(separator: " "))
        case "whoami":
            print("beastmeds@sandbox")
        case "date":
            print(Date().description)
        case "env":
            print("SANDBOX=true")
            print("USER=beastmeds")
            print("HOME=/sandbox")
            print("SHELL=/bin/bash")
        case "ps":
            print("  PID  PROCESS", .info)
            print("  101  beast-bot")
            print("  102  mc-server")
            print("  103  monitor")
        case "status":
            print("--- sandbox status ---", .system)
            print("  beast-bot    running")
            print("  mc-server    running")
            print("  discord-bot  stopped", .dim)
            print("  voltra-api   error", .error)
        default:
            print("command not found: \(cmd). try \"help\"", .error)
        }
    }

    private func resolve(_ path: String) -> String {
        if path.hasPrefix("/") { return path }
        if path == ".." {
            let parts = cwd.split(separator: "/")
            return parts.count > 1 ? "/" + parts.dropLast().joined(separator: "/") : "/sandbox"
        }
        return cwd + "/" + path
    }
}

// MARK: - Virtual Filesystem

struct FSNode {
    enum NodeType { case file, directory }
    let type: NodeType
    var children: [String]?
    var content: String?
    var size: Int
}

struct SandboxFS {
    static func initial() -> [String: FSNode] {
        var fs: [String: FSNode] = [:]
        fs["/sandbox"] = FSNode(type: .directory, children: ["apps","logs","scripts","tmp"], content: nil, size: 0)
        fs["/sandbox/apps"] = FSNode(type: .directory, children: ["beast-bot.js","config.json"], content: nil, size: 0)
        fs["/sandbox/logs"] = FSNode(type: .directory, children: ["debug.log","error.log"], content: nil, size: 0)
        fs["/sandbox/scripts"] = FSNode(type: .directory, children: ["test.sh","deploy.sh"], content: nil, size: 0)
        fs["/sandbox/tmp"] = FSNode(type: .directory, children: [], content: nil, size: 0)
        fs["/sandbox/apps/beast-bot.js"] = FSNode(type: .file, children: nil, content: "// BeastBot entry\nconst bot = require(\"./core\");\nbot.start();", size: 47)
        fs["/sandbox/apps/config.json"] = FSNode(type: .file, children: nil, content: "{\n  \"prefix\": \"!\",\n  \"debug\": true,\n  \"port\": 3000\n}", size: 48)
        fs["/sandbox/logs/debug.log"] = FSNode(type: .file, children: nil, content: "[INFO] Bot started\n[DEBUG] Connected to WhatsApp\n[DEBUG] Loaded 180 commands", size: 64)
        fs["/sandbox/logs/error.log"] = FSNode(type: .file, children: nil, content: "[ERR] 401 Unauthorized - check API key\n[ERR] Socket timeout after 30s", size: 68)
        fs["/sandbox/scripts/test.sh"] = FSNode(type: .file, children: nil, content: "#!/bin/bash\necho \"running tests...\"\nnpm test", size: 42)
        fs["/sandbox/scripts/deploy.sh"] = FSNode(type: .file, children: nil, content: "#!/bin/bash\npm2 restart beast-bot\necho \"deployed!\"", size: 47)
        return fs
    }
}
