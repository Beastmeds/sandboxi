import SwiftUI

struct LicenseGateView: View {
    @State private var keyInput: String = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var errorMsg: String = ""
    @State private var isChecking: Bool = false
    @AppStorage("isLicensed") private var isLicensed: Bool = false
    @AppStorage("licenseKey") private var licenseKey: String = ""

    // ─── EDIT YOUR VALID KEYS HERE ───────────────────────────────────────────
    private let validKeys: Set<String> = [
        "BSMP-2024-AAAA-0001",
        "BSMP-2024-BBBB-0002",
        "BSMP-2024-CCCC-0003",
        "BSMP-DEMO-FREE-TEST"
    ]
    // ─────────────────────────────────────────────────────────────────────────

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo block
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "0a0a0a"))
                            .frame(width: 90, height: 90)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "00ff41"), lineWidth: 1)
                            )
                        Text("BS")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "00ff41"))
                    }

                    Text("BeastSandbox")
                        .font(.system(size: 22, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "00ff41"))

                    Text("// enter license key to continue")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "006622"))
                }
                .padding(.bottom, 40)

                // Input field
                VStack(spacing: 6) {
                    HStack {
                        Text("> ")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color(hex: "00aa22"))
                        TextField("BSMP-XXXX-XXXX-XXXX", text: $keyInput)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color(hex: "00ff41"))
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .keyboardType(.asciiCapable)
                            .onChange(of: keyInput) { v in
                                keyInput = v.uppercased()
                                errorMsg = ""
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "050505"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(errorMsg.isEmpty ? Color(hex: "003300") : Color(hex: "aa2222"), lineWidth: 1)
                    )
                    .cornerRadius(6)
                    .offset(x: shakeOffset)

                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color(hex: "ff4444"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

                // Activate button
                Button(action: activate) {
                    HStack {
                        if isChecking {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                .scaleEffect(0.8)
                        }
                        Text(isChecking ? "checking..." : "activate license")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "00ff41"))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 32)
                .disabled(keyInput.trimmingCharacters(in: .whitespaces).isEmpty || isChecking)
                .opacity(keyInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)

                Spacer()

                Text("BeastSMP © 2024")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color(hex: "222222"))
                    .padding(.bottom, 20)
            }
        }
    }

    private func activate() {
        let key = keyInput.trimmingCharacters(in: .whitespaces)
        isChecking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isChecking = false
            if validKeys.contains(key) {
                licenseKey = key
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLicensed = true
                }
            } else {
                errorMsg = "[ERR] invalid license key"
                withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) {
                    shakeOffset = -10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) {
                        shakeOffset = 10
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) {
                        shakeOffset = 0
                    }
                }
            }
        }
    }
}
