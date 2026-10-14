import SwiftUI

struct QuietPlaceView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var feedback: String? = nil
    @State private var selectedTab: AppNavTab = .suggestions

    private let backgroundColor = Color(red: 0.91, green: 0.96, blue: 1.00)
    private let darkText = Color(red: 0.08, green: 0.10, blue: 0.14)
    private let blue = Color(red: 0.38, green: 0.68, blue: 0.88)
    private let lightBlue = Color(red: 0.84, green: 0.93, blue: 1.00)

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // Back
                    Button { dismiss() } label: {
                        Image(systemName: lm.backChevron)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.80))
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(Color.gray.opacity(0.18), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    // Recommended
                    Text(lm.l("RECOMMENDED"))
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.7)
                        .foregroundStyle(blue)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .background(lightBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(.top, 14)

                    // Title
                    Text(lm.l("Move to a Quiet Place"))
                        .font(.system(size: 29, weight: .bold))
                        .foregroundStyle(darkText)
                        .padding(.top, 10)

                    // Image
                    HStack {
                        Spacer()
                        Image("quiet_place")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 190)
                        Spacer()
                    }
                    .padding(.top, 10)

                    // Try this
                    Text(lm.l("Try this"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(darkText)
                        .padding(.top, 12)

                    VStack(spacing: 0) {
                        QPStep(number: "01", text: lm.l("Move away from loud sounds."))
                        QPDivider()
                        QPStep(number: "02", text: lm.l("Reduce unnecessary talking."))
                        QPDivider()
                        QPStep(number: "03", text: lm.l("Give your child some personal space."))
                        QPDivider()
                        QPStep(number: "04", text: lm.l("Wait calmly without forcing interaction."))
                    }
                    .padding(.top, 12)

                    // Avoid
                    Text(lm.l("Avoid"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(darkText)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 15) {
                        QPAvoid(text: lm.l("Asking too many questions."))
                        QPAvoid(text: lm.l("Forcing eye contact."))
                        QPAvoid(text: lm.l("Moving quickly between activities."))
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.avoidBg)
                    .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 17)
                            .stroke(AppColors.avoidBorder, lineWidth: 1)
                    }
                    .padding(.top, 14)

                    // Separator
                    Rectangle()
                        .fill(Color.white.opacity(0.60))
                        .frame(height: 1)
                        .padding(.top, 24)

                    // Feedback
                    AppFeedbackSection(feedback: $feedback)
                        .padding(.top, 20)

                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 20)
            }

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
        .onChange(of: feedback) { _, newValue in
            if let fb = newValue { FeedbackStore.shared.record(strategy: "Quiet Place", feedback: fb) }
        }
    }
}


// MARK: - Step

struct QPStep: View {

    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Text(number)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.gray)
                .frame(width: 28, height: 28)
                .background(.white)
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 0.19, green: 0.24, blue: 0.33))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .frame(minHeight: 48)
    }
}


// MARK: - Divider

struct QPDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.95))
            .frame(height: 1.5)
            .padding(.leading, 42)
    }
}


// MARK: - Avoid Row

struct QPAvoid: View {

    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.avoidIcon)

            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.avoidText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}


// MARK: - Preview

#Preview {
    QuietPlaceView()
}
