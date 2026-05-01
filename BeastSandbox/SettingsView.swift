import SwiftUI

struct SettingsView: View {
    @AppStorage("isLicensed") private var isLicensed: Bool = false
    @AppStorage("licenseKey") private var licenseKey: String = ""
    @State private var showRevokeConfirm = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("// settings")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(hex: "0a0a0a"))
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "00ff41").opacity(0.3)), alignment: .bottom)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        settingsSection("license") {
                            settingsRow(label: "status", value: isLicensed ? "active" : "unlicensed", valueColor: isLicensed ? Color(hex: "00ff41") : Color(hex: "ff4444"))
                            if isLicensed {
                                settingsRow(label: "key", value: maskedKey(licenseKey), valueColor: Color(hex: "00aaff"))
                            }
                        }

                        settingsSection("sandbox") {
                            settingsRow(label: "version", value: "1.0.0")
                            settingsRow(label: "build", value: "2024.1")
                            settingsRow(label: "filesystem", value: "virtual / in-memory")
                            settingsRow(label: "root", value: "/sandbox")
                        }

                        settingsSection("runtime") {
                            settingsRow(label: "js engine", value: "simulated")
                            settingsRow(label: "network", value: "simulated")
                            settingsRow(label: "storage", value: "UserDefaults")
                        }

                        if isLicensed {
                            VStack(spacing: 12) {
                                Button(action: { showRevokeConfirm = true }) {
                                    Text("revoke license")
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(Color(hex: "ff4444"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "441111"), lineWidth: 0.5))
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.vertical, 16)
                        }

                        Spacer().frame(height: 40)

                        Text("BeastSMP © 2024 — beastmeds")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color(hex: "222222"))
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .alert("revoke license?", isPresented: $showRevokeConfirm) {
            Button("revoke", role: .destructive) {
                isLicensed = false
                licenseKey = ""
            }
            Button("cancel", role: .cancel) { }
        } message: {
            Text("you will need to re-enter your key")
        }
    }

    private func maskedKey(_ key: String) -> String {
        guard key.count >= 8 else { return "****" }
        return String(key.prefix(4)) + "****" + String(key.suffix(4))
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color(hex: "444444"))
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 6)
            VStack(spacing: 0) {
                content()
            }
            .background(Color(hex: "0a0a0a"))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "1a1a1a"), lineWidth: 0.5))
            .cornerRadius(4)
            .padding(.horizontal, 12)
        }
    }

    private func settingsRow(label: String, value: String, valueColor: Color = Color(hex: "555555")) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color(hex: "888888"))
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "111111")), alignment: .bottom)
    }
}
