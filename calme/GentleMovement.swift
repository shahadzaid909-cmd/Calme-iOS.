import SwiftUI

struct GentleMovement: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: AppNavTab = .suggestions
    @State private var feedback: String? = nil

    private let backgroundColor = Color(red: 233/255, green: 243/255, blue: 255/255)
    private let textColor       = Color(red: 30/255,  green: 43/255,  blue: 61/255)
    private let blueColor       = Color(red: 113/255, green: 179/255, blue: 221/255)

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {

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
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.7)
                        .foregroundColor(blueColor)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .background(AppColors.lightBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .padding(.top, 14)

                    // MARK: Title

                    Text(lm.l("Gentle Movement"))
                        .font(.system(size: 29, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 10)

                    // MARK: Image

                    Image("GentleMovement")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)

                    // MARK: Try This

                    Text(lm.l("Try this"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 12)

                    // MARK: Steps

                    VStack(spacing: 0) {
                        GMStepRow(number: "01", text: lm.l("Invite your child to move at their own pace."))
                        GMDivider()
                        GMStepRow(number: "02", text: lm.l("Try slow walking or gentle stretching."))
                        GMDivider()
                        GMStepRow(number: "03", text: lm.l("Keep movements simple and predictable."))
                        GMDivider()
                        GMStepRow(number: "04", text: lm.l("Allow breaks whenever needed."))
                    }
                    .padding(.top, 12)

                    // MARK: Avoid

                    Text(lm.l("Avoid"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 13) {
                        GMAvoidRow(text: lm.l("Forcing your child to move."))
                        GMAvoidRow(text: lm.l("Using fast or intense movements."))
                        GMAvoidRow(text: lm.l("Continuing if your child seems overwhelmed."))
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
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: feedback) { _, newValue in
            if let fb = newValue { FeedbackStore.shared.record(strategy: "Movement", feedback: fb) }
        }
    }
}


// MARK: - Step Row

private struct GMStepRow: View {

    let number: String
    let text: String

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
                .foregroundColor(AppColors.darkText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 52, alignment: .center)
    }
}


// MARK: - Divider

private struct GMDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.95))
            .frame(height: 1)
            .padding(.leading, 41)
    }
}


// MARK: - Avoid Row

private struct GMAvoidRow: View {

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

            Spacer(minLength: 0)
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        GentleMovement()
    }
}
