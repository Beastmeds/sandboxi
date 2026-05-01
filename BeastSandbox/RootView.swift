import SwiftUI

struct RootView: View {
    @AppStorage("isLicensed") private var isLicensed: Bool = false
    @AppStorage("licenseKey") private var licenseKey: String = ""

    var body: some View {
        if isLicensed {
            MainTabView()
        } else {
            LicenseGateView()
        }
    }
}
