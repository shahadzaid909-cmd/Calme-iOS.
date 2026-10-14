import SwiftUI

struct WhatUsuallyHelpsView: View {

    private let situation: QuickCheckInput.Situation
    private let intensity: QuickCheckInput.Intensity

    init(situation: QuickCheckInput.Situation, intensity: QuickCheckInput.Intensity) {
        self.situation = situation
        self.intensity = intensity
    }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedOptions: Set<String> = []
    @State private var selectedTab: AppNavTab = .suggestions

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            Color(red: 233/255, green: 243/255, blue: 255/255)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Back Button

                    Button { dismiss() } label: {
                        Image(systemName: lm.backChevron)
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(Color(red: 42/255, green: 54/255, blue: 73/255))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.72)))
                            .overlay(
                                Circle().stroke(
                                    Color(red: 211/255, green: 224/255, blue: 237/255),
                                    lineWidth: 1
                                )
                            )
                    }
                    .padding(.leading, 24)
                    .padding(.top, 8)

                    // MARK: Title

                    Text(lm.l("What usually helps?"))
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(Color(red: 28/255, green: 39/255, blue: 55/255))
                        .padding(.horizontal, 40)
                        .padding(.top, 18)

                    // MARK: Subtitle

                    Text(lm.l("Select anything that helps your child feel\ncalmer"))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(red: 108/255, green: 121/255, blue: 140/255))
                        .lineSpacing(5)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)

                    // MARK: Cards
                    // Note: card titles are localized for display; internal English keys
                    // drive selection state and are passed on to SuggestionsScreen.

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 18),
                            GridItem(.flexible(), spacing: 18)
                        ],
                        spacing: 20
                    ) {
                        WHCard(title: lm.l("Quiet Place"),        icon: .quietPlace,   selected: selectedOptions.contains("Quiet Place"))        { toggle("Quiet Place") }
                        WHCard(title: lm.l("Breathing Technique"), icon: .breathing,    selected: selectedOptions.contains("Breathing Technique")) { toggle("Breathing Technique") }
                        WHCard(title: lm.l("Headphones"),         icon: .headphones,   selected: selectedOptions.contains("Headphones"))          { toggle("Headphones") }
                        WHCard(title: lm.l("Music"),              icon: .music,        selected: selectedOptions.contains("Music"))               { toggle("Music") }
                        WHCard(title: lm.l("Deep Pressure"),      icon: .deepPressure, selected: selectedOptions.contains("Deep Pressure"))       { toggle("Deep Pressure") }
                        WHCard(title: lm.l("Movement"),           icon: .movement,     selected: selectedOptions.contains("Movement"))            { toggle("Movement") }
                        WHCard(title: lm.l("Water"),              icon: .water,        selected: selectedOptions.contains("Water"))               { toggle("Water") }
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 40)

                    // MARK: Show Suggestions Button

                    NavigationLink {
                        SuggestionsScreen(input: QuickCheckInput(
                            situation: situation,
                            intensity: intensity,
                            preferredStrategies: Array(selectedOptions)
                        ))
                    } label: {
                        Text(lm.l("Show Suggestions"))
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(red: 98/255, green: 177/255, blue: 216/255))
                            )
                    }
                    .padding(.horizontal, 34)
                    .padding(.top, 40)

                    Color.clear.frame(height: 100)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }

    // MARK: - Toggle (always uses English internal keys)

    private func toggle(_ item: String) {
        if selectedOptions.contains(item) {
            selectedOptions.remove(item)
        } else {
            selectedOptions.insert(item)
        }
    }
}


// MARK: - Card Icon Type

private enum WHIcon {
    case quietPlace, breathing, headphones, music, deepPressure, movement, water
}


// MARK: - Card

private struct WHCard: View {

    let title: String
    let icon: WHIcon
    let selected: Bool
    let action: () -> Void

    private let blue      = Color(red: 127/255, green: 179/255, blue: 213/255)
    private let textColor = Color(red: 42/255,  green: 54/255,  blue: 73/255)
    private let grayIcon  = Color(red: 105/255, green: 117/255, blue: 135/255)

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    WHIconView(icon: icon, color: selected ? blue : grayIcon)
                    Spacer()
                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(blue))
                    }
                }

                Spacer()

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 19)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .background(
                RoundedRectangle(cornerRadius: 21)
                    .fill(
                        selected
                        ? Color(red: 225/255, green: 240/255, blue: 252/255)
                        : Color.white
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 21)
                    .stroke(selected ? blue : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.045), radius: 7, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Card Icons

private struct WHIconView: View {

    let icon: WHIcon
    let color: Color

    var body: some View {
        ZStack {
            switch icon {
            case .quietPlace:
                ZStack {
                    Image(systemName: "house")
                        .font(.system(size: 25, weight: .medium))

                    ZStack {
                        Circle().fill(color).frame(width: 13, height: 13)
                        Text("!")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 10, y: 9)
                }

            case .breathing:
                Image(systemName: "leaf")
                    .font(.system(size: 25, weight: .medium))

            case .headphones:
                Image(systemName: "headphones")
                    .font(.system(size: 25, weight: .medium))

            case .music:
                Image(systemName: "music.note")
                    .font(.system(size: 27, weight: .medium))

            case .deepPressure:
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 24, weight: .medium))

            case .movement:
                Image(systemName: "figure.walk")
                    .font(.system(size: 25, weight: .medium))

            case .water:
                Image(systemName: "drop.fill")
                    .font(.system(size: 25, weight: .medium))
            }
        }
        .foregroundColor(color)
        .frame(width: 36, height: 32)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        WhatUsuallyHelpsView(situation: .loudNoise, intensity: .moderate)
    }
}
