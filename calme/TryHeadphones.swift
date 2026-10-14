import SwiftUI

struct TryHeadphones: View {

    @Environment(\.dismiss) private var dismiss

    @State private var feedback: String? = nil
    @State private var selectedTab: AppNavTab = .suggestions

    private let backgroundColor = Color(red: 233/255, green: 243/255, blue: 255/255)
    private let textColor       = Color(red: 30/255,  green: 43/255,  blue: 61/255)
    private let blueColor       = Color(red: 113/255, green: 179/255, blue: 221/255)

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
                            .foregroundColor(textColor)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.65)))
                            .overlay(
                                Circle().stroke(
                                    Color(red: 207/255, green: 221/255, blue: 235/255),
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    // MARK: Recommended

                    Text(lm.l("RECOMMENDED"))
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.4)
                        .foregroundColor(blueColor)
                        .padding(.horizontal, 13)
                        .frame(height: 25)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(red: 222/255, green: 238/255, blue: 252/255))
                        )
                        .padding(.top, 14)

                    // MARK: Title

                    Text(lm.l("Try Headphones"))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 10)

                    // MARK: Image

                    Image("سماع")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 285, height: 210)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 2)

                    // MARK: Try This

                    Text(lm.l("Try this"))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(textColor)

                    // MARK: Steps

                    VStack(spacing: 0) {
                        THStepRow(number: "01", text: lm.l("Offer the headphones calmly."))
                        THDivider()
                        THStepRow(number: "02", text: lm.l("Let your child choose whether to wear them."))
                        THDivider()
                        THStepRow(number: "03", text: lm.l("Make sure the headphones fit comfortably."))
                        THDivider()
                        THStepRow(number: "04", text: lm.l("Move to a quieter place if possible."))
                    }
                    .padding(.top, 12)

                    // MARK: Avoid

                    Text(lm.l("Avoid"))
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 13) {
                        THAvoidRow(text: lm.l("Forcing your child to wear the headphones."))
                        THAvoidRow(text: lm.l("Using headphones that feel uncomfortable."))
                        THAvoidRow(text: lm.l("Increasing the volume too much."))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 22)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.avoidBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.avoidBorder, lineWidth: 1)
                    )
                    .padding(.top, 17)

                    // MARK: Feedback Section

                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.85))
                            .frame(height: 1)
                            .padding(.bottom, 20)

                        AppFeedbackSection(feedback: $feedback)
                    }
                    .padding(.top, 24)

                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: feedback) { _, newValue in
            if let fb = newValue { FeedbackStore.shared.record(strategy: "Headphones", feedback: fb) }
        }
    }
}


// MARK: - Step Row

private struct THStepRow: View {

    let number: String
    let text: String

    private let textColor = Color(red: 31/255, green: 43/255, blue: 60/255)

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(number)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 145/255, green: 153/255, blue: 165/255))
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.white))

            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(textColor)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 48)
    }
}


// MARK: - Divider

private struct THDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.85))
            .frame(height: 1)
            .padding(.leading, 40)
    }
}


// MARK: - Avoid Row

private struct THAvoidRow: View {

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
    NavigationStack {
        TryHeadphones()
    }
}
