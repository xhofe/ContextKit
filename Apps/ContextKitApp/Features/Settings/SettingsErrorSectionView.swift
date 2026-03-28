import SwiftUI

struct SettingsErrorSectionView: View {
    let errorMessage: String?

    var body: some View {
        if let errorMessage {
            Section {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
    }
}
