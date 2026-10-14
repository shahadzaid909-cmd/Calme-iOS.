import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: AppNavTab = .suggestions

    private let backgroundColor = Color(red: 234/255, green: 243/255, blue: 255/255)

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Back Button

                    Button { dismiss() } label: {
                        Image(systemName: lm.backChevron)
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.72)))
                            .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    // MARK: Title

                    Text(lm.l("Settings"))
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 18)

                    // MARK: Language Section Label

                    Text(lm.l("LANGUAGE"))
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.6)
                        .foregroundColor(Color(red: 130/255, green: 140/255, blue: 155/255))
                        .padding(.top, 36)

                    // MARK: Language Options

                    VStack(spacing: 0) {
                        SettingsLanguageRow(
                            title: "English",
                            isSelected: lm.selectedLanguage == "en"
                        ) {
                            lm.selectedLanguage = "en"
                        }

                        Rectangle()
                            .fill(Color(red: 230/255, green: 236/255, blue: 244/255))
                            .frame(height: 1)
                            .padding(.leading, 16)

                        SettingsLanguageRow(
                            title: "العربية",
                            isSelected: lm.selectedLanguage == "ar"
                        ) {
                            lm.selectedLanguage = "ar"
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.055), radius: 8, x: 0, y: 4)
                    .padding(.top, 10)

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }

            // MARK: Bottom Navigation

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }
}


// MARK: - Language Row

private struct SettingsLanguageRow: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    private let primaryBlue = Color(red: 113/255, green: 179/255, blue: 221/255)

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color(red: 30/255, green: 43/255, blue: 61/255))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(primaryBlue)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
}
