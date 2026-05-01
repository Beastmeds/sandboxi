import SwiftUI

struct NetworkView: View {
    @State private var host: String = "example.com"
    @State private var port: String = "80"
    @State private var path: String = "/"
    @State private var method: String = "GET"
    @State private var output: [NetLine] = []
    @State private var isLoading: Bool = false

    struct NetLine: Identifiable {
        let id = UUID()
        let text: String
        let color: Color
    }

    let methods = ["GET", "POST", "HEAD", "OPTIONS", "PUT", "DELETE"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("// network")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "00ff41")))
                            .scaleEffect(0.7)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "0a0a0a"))
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "00ff41").opacity(0.3)), alignment: .bottom)

                // Input fields
                VStack(spacing: 0) {
                    netRow(label: "host") {
                        TextField("host or IP", text: $host)
                            .netField()
                    }
                    netRow(label: "port") {
                        HStack(spacing: 6) {
                            TextField("80", text: $port)
                                .netField()
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                            Picker("", selection: $method) {
                                ForEach(methods, id: \.self) { m in
                                    Text(m).tag(m)
                                        .font(.system(size: 11, design: .monospaced))
                                }
                            }
                            .pickerStyle(.menu)
                            .foregroundColor(Color(hex: "00ff41"))
                            .background(Color(hex: "111111"))
                            .cornerRadius(3)
                        }
                    }
                    netRow(label: "path") {
                        TextField("/endpoint", text: $path)
                            .netField()
                    }
                }
                .background(Color(hex: "0a0a0a"))

                // Action buttons
                HStack(spacing: 8) {
                    Button("ping") { simPing() }.fmButton()
                    Button("request") { simRequest() }.fmButton()
                    Button("port scan") { simScan() }.fmButton()
                    Spacer()
                    Button("clear") { output = [] }
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "444444"))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(hex: "0d0d0d"))

                // Output
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(output) { line in
                                Text(line.text)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(line.color)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(line.id)
                            }
                        }
                        .padding(10)
                    }
                    .onChange(of: output.count) { _ in
                        if let last = output.last { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .background(Color.black)
            }
        }
    }

    private func netRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(hex: "555555"))
                .frame(width: 40, alignment: .leading)
            content()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "111111")), alignment: .bottom)
    }

    private func add(_ text: String, _ color: Color = Color(hex: "00ff41")) {
        output.append(NetLine(text: text, color: color))
    }

    private func simPing() {
        isLoading = true
        add("PING \(host):", Color(hex: "00aaff"))
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                let ms = String(format: "%.1f", Double.random(in: 5...120))
                let ok = Double.random(in: 0...1) > 0.1
                add("64 bytes from \(host): icmp_seq=\(i) time=\(ms)ms \(ok ? "TTL=64" : "timeout")",
                    ok ? Color(hex: "00ff41") : Color(hex: "ff4444"))
                if i == 3 { isLoading = false }
            }
        }
    }

    private func simRequest() {
        isLoading = true
        add("> \(method) http://\(host):\(port)\(path)", Color(hex: "00aaff"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let codes = [200, 201, 400, 401, 403, 404, 500]
            let code = codes[Int.random(in: 0...2)] // bias toward success
            let ok = code < 300
            add("< HTTP/1.1 \(code) \(statusText(code))", ok ? Color(hex: "00ff41") : Color(hex: "ffaa00"))
            add("< Content-Type: application/json", Color(hex: "444444"))
            add("< X-Sandbox: true", Color(hex: "444444"))
            if ok {
                add("< {\"status\":\"ok\",\"path\":\"\(path)\"}")
            } else {
                add("< {\"error\":true,\"code\":\(code)}", Color(hex: "ff4444"))
            }
            isLoading = false
        }
    }

    private func simScan() {
        isLoading = true
        add("scanning \(host)...", Color(hex: "00aaff"))
        let ports: [(Int, String)] = [(22,"ssh"),(80,"http"),(443,"https"),(3000,"node"),(3306,"mysql"),(6379,"redis"),(8080,"http-alt"),(25565,"minecraft")]
        for (i, (p, svc)) in ports.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                let open = Bool.random()
                let portStr = String(p).padding(toLength: 7, withPad: " ", startingAt: 0)
                let svcStr = svc.padding(toLength: 12, withPad: " ", startingAt: 0)
                add("\(portStr)\(svcStr)\(open ? "OPEN" : "closed")",
                    open ? Color(hex: "00ff41") : Color(hex: "333333"))
                if i == ports.count - 1 { isLoading = false }
            }
        }
    }

    private func statusText(_ code: Int) -> String {
        switch code {
        case 200: return "OK"
        case 201: return "Created"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 500: return "Internal Server Error"
        default: return "Unknown"
        }
    }
}

extension TextField {
    func netField() -> some View {
        self
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(Color(hex: "00ff41"))
            .accentColor(Color(hex: "00ff41"))
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(hex: "111111"))
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color(hex: "222222"), lineWidth: 0.5))
            .cornerRadius(3)
    }
}
