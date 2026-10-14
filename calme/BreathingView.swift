import SwiftUI

struct BreathingView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var feedback: String? = nil
    @State private var selectedTab: AppNavTab = .suggestions

    private let backgroundColor = Color(red: 233/255, green: 243/255, blue: 255/255)
    private let darkText = Color(red: 31/255, green: 43/255, blue: 60/255)
    private let blue = Color(red: 111/255, green: 181/255, blue: 222/255)
    private let lightBlue = Color(red: 218/255, green: 235/255, blue: 250/255)

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Back Button

                    Button { dismiss() } label: {
                        Image(systemName: lm.backChevron)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(darkText)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.78)))
                            .overlay(
                                Circle().stroke(
                                    Color(red: 205/255, green: 219/255, blue: 234/255),
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    // MARK: Recommended Label

                    Text(lm.l("RECOMMENDED"))
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.7)
                        .foregroundColor(blue)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .background(lightBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .padding(.top, 14)

                    // MARK: Title

                    Text(lm.l("Breathing Technique"))
                        .font(.system(size: 29, weight: .bold))
                        .foregroundColor(darkText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.top, 13)

                    // MARK: Image

                    HStack {
                        Spacer()
                        Image("breathing")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 170)
                        Spacer()
                    }
                    .padding(.top, 7)

                    // MARK: Try This

                    Text(lm.l("Try this"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(darkText)
                        .padding(.top, 11)

                    // MARK: Steps

                    VStack(spacing: 0) {
                        BreathingStepRow(number: "01", text: lm.l("Ask your child to sit comfortably."))
                        BreathingDivider()
                        BreathingStepRow(number: "02", text: lm.l("Breathe in slowly through the nose for 4 seconds."))
                        BreathingDivider()
                        BreathingStepRow(number: "03", text: lm.l("Hold the breath gently for 4 seconds."))
                        BreathingDivider()
                        BreathingStepRow(number: "04", text: lm.l("Breathe out slowly through the mouth for 4 seconds."))
                    }
                    .padding(.top, 10)

                    // MARK: Avoid

                    Text(lm.l("Avoid"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(darkText)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 13) {
                        BreathingAvoidRow(text: lm.l("Forcing deep or fast breathing."))
                        BreathingAvoidRow(text: lm.l("Counting out loud if it causes stress."))
                        BreathingAvoidRow(text: lm.l("Continuing if your child feels uncomfortable."))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 17)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.avoidBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.avoidBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 13)

                    // MARK: Separator

                    Rectangle()
                        .fill(Color.white.opacity(0.75))
                        .frame(height: 1)
                        .padding(.top, 24)

                    // MARK: Feedback

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
            if let fb = newValue { FeedbackStore.shared.record(strategy: "Breathing Technique", feedback: fb) }
        }
    }
}


// MARK: - Step Row

private struct BreathingStepRow: View {

    let number: String
    let text: String

    private let textColor = Color(red: 31/255, green: 43/255, blue: 60/255)

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            Text(number)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(red: 145/255, green: 151/255, blue: 161/255))
                .frame(width: 27, height: 27)
                .background(Color.white)
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 52, alignment: .center)
    }
}


// MARK: - Divider

private struct BreathingDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.95))
            .frame(height: 1)
            .padding(.leading, 41)
    }
}


// MARK: - Avoid Row

private struct BreathingAvoidRow: View {

    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.avoidIcon)

            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppColors.avoidText)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)
        }
    }
}


// MARK: - Preview

#Preview {
    BreathingView()
}
