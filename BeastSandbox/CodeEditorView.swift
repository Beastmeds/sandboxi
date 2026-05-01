import SwiftUI

struct CodeEditorView: View {
    @State private var code: String = "// BeastSandbox editor\n// write your code here\n\nconsole.log(\"hello sandbox\");"
    @State private var filename: String = "untitled.js"
    @State private var output: String = ""
    @State private var outputColor: Color = Color(hex: "00ff41")

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("// editor")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                    Spacer()
                    TextField("filename", text: $filename)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "00aaff"))
                        .multilineTextAlignment(.trailing)
                        .autocapitalization(.none)
                        .frame(maxWidth: 160)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "0a0a0a"))
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "00ff41").opacity(0.3)), alignment: .bottom)

                // Toolbar
                HStack(spacing: 8) {
                    Button(action: runCode) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            Text("run")
                                .font(.system(size: 11, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color(hex: "00ff41"))
                        .cornerRadius(3)
                    }
                    Button("clear") {
                        code = ""
                        output = ""
                    }
                    .fmButton()
                    Button("save") {
                        output = "[saved] /sandbox/tmp/\(filename)"
                        outputColor = Color(hex: "00aaff")
                    }
                    .fmButton()
                    Spacer()
                    Text("\(code.split(separator: "\n", omittingEmptySubsequences: false).count) lines")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(hex: "333333"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "0d0d0d"))

                // Code area
                TextEditor(text: $code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(hex: "00ff41"))
                    .scrollContentBackground(.hidden)
                    .background(Color(hex: "050505"))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(minHeight: 240)

                // Output
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("output")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "444444"))
                        Spacer()
                        Button("clear") { output = "" }
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "333333"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "0d0d0d"))
                    .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "111111")), alignment: .top)

                    ScrollView {
                        Text(output.isEmpty ? "—" : output)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(output.isEmpty ? Color(hex: "222222") : outputColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                    }
                    .frame(height: 80)
                    .background(Color.black)
                }
            }
        }
    }

    private func runCode() {
        // Basic simulation of JS-like execution feedback
        let lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var results: [String] = []
        var hasError = false

        for line in lines {
            let t = line.trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("//") || t.isEmpty { continue }
            if t.hasPrefix("console.log(") {
                let inner = t.dropFirst(12).dropLast(2)
                results.append("[log] \(inner)")
            } else if t.hasPrefix("console.error(") {
                let inner = t.dropFirst(14).dropLast(2)
                results.append("[err] \(inner)")
                hasError = true
            } else if t.contains("===") || t.contains("!==") || t.contains("==") {
                results.append("[eval] expression parsed")
            } else if t.hasPrefix("const ") || t.hasPrefix("let ") || t.hasPrefix("var ") {
                let varName = t.split(separator: " ")[1].split(separator: "=")[0]
                results.append("[decl] \(varName) declared")
            } else if t.hasSuffix("{") || t == "}" {
                continue
            }
        }

        if results.isEmpty { results.append("[ok] executed — no output") }
        output = results.joined(separator: "\n")
        outputColor = hasError ? Color(hex: "ff4444") : Color(hex: "00ff41")
    }
}
