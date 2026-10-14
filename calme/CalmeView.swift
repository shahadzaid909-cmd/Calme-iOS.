import SwiftUI

struct CalmeView: View {

    @State private var selectedTab: AppNavTab = .suggestions

    let backgroundTop    = Color(red: 231/255, green: 239/255, blue: 251/255)
    let backgroundBottom = Color(red: 225/255, green: 235/255, blue: 249/255)
    let darkBlue         = Color(red: 24/255,  green: 43/255,  blue: 78/255)
    let buttonBlue       = Color(red: 120/255, green: 177/255, blue: 215/255)

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            LinearGradient(
                colors: [backgroundTop, backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Calme")
                                .font(.system(size: 27, weight: .bold))
                                .foregroundColor(.black)

                            Text(lm.l("A calmer moment starts here."))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(red: 115/255, green: 119/255, blue: 126/255))
                        }

                        Spacer()

                        NavigationLink { SettingsView() } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.white.opacity(0.72)))
                                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 26)

                    // MARK: Main Suggestion Card

                    VStack(alignment: .leading, spacing: 0) {

                        Text(lm.l("Need a calmer moment?"))
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(darkBlue)

                        Text(lm.l("Tell us what's happening, and we'll\nhelp you find what works."))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 82/255, green: 94/255, blue: 111/255))
                            .lineSpacing(5)
                            .padding(.top, 11)

                        NavigationLink {
                            QuickCheckView()
                        } label: {
                            Text(lm.l("Get Calming Suggestions"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 57)
                                .background(buttonBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
                    .padding(.top, 30)

                    // MARK: What Usually Helps

                    Text(lm.l("What usually helps?"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(darkBlue)
                        .padding(.top, 40)

                    // MARK: Helper Cards

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        NavigationLink { TryHeadphones() } label: {
                            HelperCard(
                                icon: "headphones",
                                title: lm.l("Headphones"),
                                iconColor: Color(red: 119/255, green: 169/255, blue: 235/255),
                                iconBackground: Color(red: 235/255, green: 244/255, blue: 255/255)
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink { QuietPlaceView() } label: {
                            HelperCard(
                                icon: "house.fill",
                                title: lm.l("Quiet Place"),
                                iconColor: Color(red: 175/255, green: 143/255, blue: 235/255),
                                iconBackground: Color(red: 244/255, green: 237/255, blue: 255/255)
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink { BreathingView() } label: {
                            HelperCard(
                                icon: "leaf.fill",
                                title: lm.l("Breathing Technique"),
                                iconColor: Color(red: 106/255, green: 199/255, blue: 132/255),
                                iconBackground: Color(red: 235/255, green: 250/255, blue: 238/255)
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink { QuietMusic() } label: {
                            HelperCard(
                                icon: "music.note",
                                title: lm.l("Music"),
                                iconColor: Color(red: 218/255, green: 142/255, blue: 164/255),
                                iconBackground: Color(red: 255/255, green: 237/255, blue: 243/255)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 17)

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }

            // MARK: Bottom Navigation

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
    }
}


// MARK: - Helper Card

struct HelperCard: View {

    let icon: String
    let title: String
    let iconColor: Color
    let iconBackground: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(red: 20/255, green: 36/255, blue: 58/255))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 116)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.045), radius: 7, x: 0, y: 3)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        CalmeView()
    }
}
