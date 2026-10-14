import SwiftUI

struct QuickCheckView: View {

    // MARK: - State

    @State private var selectedSituation: Situation = .loudNoise
    @State private var selectedIntensity: Intensity = .moderate
    @State private var selectedTab: AppNavTab = .suggestions

    @Environment(\.dismiss) private var dismiss

    // MARK: - Enums

    enum Situation {
        case loudNoise, brightLights, crowdedPlace, changeRoutine
    }

    enum Intensity {
        case little, moderate, lot
    }

    // MARK: - Colors

    private let backgroundColor = Color(red: 234/255, green: 243/255, blue: 255/255)
    private let primaryBlue     = Color(red: 105/255, green: 179/255, blue: 220/255)

    // MARK: - Body

    var body: some View {

        let lm = LanguageManager.shared

        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Back Button

                    Button { dismiss() } label: {
                        Image(systemName: lm.backChevron)
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 45, height: 45)
                            .background(Circle().fill(Color.white.opacity(0.72)))
                            .overlay(
                                Circle().stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .padding(.top, 5)

                    // MARK: Title

                    Text(lm.l("Quick Check"))
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 18)

                    // MARK: Question

                    Text(lm.l("What's happening right now?"))
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.top, 12)
                        .padding(.leading, 4)

                    // MARK: Situation Cards

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        SituationCard(
                            title: lm.l("Loud Noise"),
                            icon: "speaker.wave.2.fill",
                            situation: .loudNoise,
                            selectedSituation: selectedSituation,
                            iconColor: Color(red: 105/255, green: 174/255, blue: 222/255),
                            iconBackground: Color(red: 226/255, green: 241/255, blue: 252/255)
                        ) { selectedSituation = .loudNoise }

                        SituationCard(
                            title: lm.l("Bright Lights"),
                            icon: "sun.max.fill",
                            situation: .brightLights,
                            selectedSituation: selectedSituation,
                            iconColor: Color(red: 166/255, green: 107/255, blue: 17/255),
                            iconBackground: Color(red: 255/255, green: 242/255, blue: 220/255)
                        ) { selectedSituation = .brightLights }

                        SituationCard(
                            title: lm.l("Crowded Place"),
                            icon: "person.3.fill",
                            situation: .crowdedPlace,
                            selectedSituation: selectedSituation,
                            iconColor: Color(red: 91/255, green: 74/255, blue: 190/255),
                            iconBackground: Color(red: 239/255, green: 235/255, blue: 255/255)
                        ) { selectedSituation = .crowdedPlace }

                        SituationCard(
                            title: lm.l("Change in Routine"),
                            icon: "arrow.triangle.2.circlepath",
                            situation: .changeRoutine,
                            selectedSituation: selectedSituation,
                            iconColor: Color(red: 0/255, green: 139/255, blue: 121/255),
                            iconBackground: Color(red: 224/255, green: 247/255, blue: 240/255)
                        ) { selectedSituation = .changeRoutine }
                    }
                    .padding(.top, 16)

                    // MARK: Intensity

                    Text(lm.l("How intense is it?"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 36)

                    HStack(spacing: 9) {
                        IntensityButton(title: lm.l("A little"), intensity: .little,   selectedIntensity: selectedIntensity) { selectedIntensity = .little }
                        IntensityButton(title: lm.l("Moderate"), intensity: .moderate, selectedIntensity: selectedIntensity) { selectedIntensity = .moderate }
                        IntensityButton(title: lm.l("A lot"),    intensity: .lot,      selectedIntensity: selectedIntensity) { selectedIntensity = .lot }
                    }
                    .padding(.top, 14)

                    // MARK: Continue

                    NavigationLink {
                        WhatUsuallyHelpsView(
                            situation: mappedSituation,
                            intensity: mappedIntensity
                        )
                    } label: {
                        Text(lm.l("Continue"))
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(primaryBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                    }
                    .padding(.top, 30)

                    Color.clear.frame(height: 16)
                }
                .padding(.horizontal, 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }

    // MARK: - Mapping to QuickCheckInput

    private var mappedSituation: QuickCheckInput.Situation {
        switch selectedSituation {
        case .loudNoise:     return .loudNoise
        case .brightLights:  return .brightLight
        case .crowdedPlace:  return .crowdedPlace
        case .changeRoutine: return .routineChange
        }
    }

    private var mappedIntensity: QuickCheckInput.Intensity {
        switch selectedIntensity {
        case .little:   return .low
        case .moderate: return .moderate
        case .lot:      return .high
        }
    }
}


// MARK: - Situation Card

private struct SituationCard: View {

    let title: String
    let icon: String
    let situation: QuickCheckView.Situation
    let selectedSituation: QuickCheckView.Situation?
    let iconColor: Color
    let iconBackground: Color
    let action: () -> Void

    private var isSelected: Bool { selectedSituation == situation }
    private let selectedBlue = Color(red: 113/255, green: 178/255, blue: 218/255)

    var body: some View {
        Button(action: action) {
            VStack(spacing: 13) {

                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                        .frame(width: 40, height: 40)

                    if isSelected {
                        Circle()
                            .fill(selectedBlue)
                            .frame(width: 22, height: 22)
                            .overlay {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 9, y: -5)
                    }
                }

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 55/255, green: 66/255, blue: 86/255))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 21))
            .overlay {
                RoundedRectangle(cornerRadius: 21)
                    .stroke(
                        isSelected ? Color(red: 104/255, green: 178/255, blue: 222/255) : Color.clear,
                        lineWidth: 1.6
                    )
            }
            .shadow(color: .black.opacity(0.065), radius: 9, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Intensity Button

private struct IntensityButton: View {

    let title: String
    let intensity: QuickCheckView.Intensity
    let selectedIntensity: QuickCheckView.Intensity
    let action: () -> Void

    private var isSelected: Bool { intensity == selectedIntensity }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                .foregroundColor(
                    isSelected
                    ? Color(red: 112/255, green: 178/255, blue: 218/255)
                    : Color(red: 82/255,  green: 92/255,  blue: 108/255)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color(red: 104/255, green: 178/255, blue: 222/255) : Color.clear,
                            lineWidth: 1.5
                        )
                }
                .shadow(color: .black.opacity(0.055), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview

#Preview {
    QuickCheckView()
}
