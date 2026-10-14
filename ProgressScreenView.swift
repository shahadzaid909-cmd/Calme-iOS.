import SwiftUI

struct ProgressScreenView: View {

    @State private var selectedTab: AppNavTab = .progress

    private let backgroundColor = Color(red: 232/255, green: 243/255, blue: 255/255)
    private let darkText  = Color(red: 29/255,  green: 35/255,  blue: 43/255)
    private let secondaryText = Color(red: 105/255, green: 116/255, blue: 133/255)
    private let blue = Color(red: 116/255, green: 181/255, blue: 218/255)

    // MARK: - Live data

    private var topStrategies: [(strategy: String, icon: String, rate: Double)] {
        FeedbackStore.shared.rankedStrategies.prefix(3).map {
            (strategy: $0.strategy, icon: strategyIcon($0.strategy), rate: $0.rate)
        }
    }

    private var topTriggers: [(situation: String, icon: String, count: Int)] {
        FeedbackStore.shared.triggerCounts.prefix(3).map {
            (situation: $0.situation, icon: situationIcon($0.situation), count: $0.count)
        }
    }

    private func strategyIcon(_ s: String) -> String {
        switch s {
        case "Headphones":          return "headphones"
        case "Quiet Place":         return "house.fill"
        case "Breathing Technique": return "leaf"
        case "Movement":            return "figure.walk"
        case "Music":               return "music.note"
        case "Deep Pressure":       return "hand.raised.fill"
        case "Water":               return "drop.fill"
        default:                    return "sparkles"
        }
    }

    private func situationIcon(_ s: String) -> String {
        switch s {
        case "Loud Noise":      return "speaker.wave.3.fill"
        case "Crowded Place":   return "person.3.fill"
        case "Bright Lights":   return "sun.max.fill"
        case "Routine Changes": return "shuffle"
        default:                return "questionmark.circle"
        }
    }

    // MARK: - Body

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header

                    Text(lm.l("What works for your child"))
                        .font(.system(size: 29, weight: .bold))
                        .foregroundColor(darkText)
                        .tracking(-0.7)
                        .padding(.top, 46)

                    Text(lm.l("Based on previous experiences"))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(secondaryText)
                        .padding(.top, 3)

                    // MARK: Most Helpful

                    HStack {
                        Text(lm.l("Most helpful"))
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(darkText)

                        Spacer()

                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(blue.opacity(0.55))
                    }
                    .padding(.top, 63)

                    // MARK: Helpful Card (live data)

                    if !topStrategies.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(topStrategies, id: \.strategy) { item in
                                ProgressHelpfulRow(
                                    icon: item.icon,
                                    title: lm.l(item.strategy),
                                    value: item.rate,
                                    percentage: "\(Int(item.rate * 100))%"
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 22)
                        .background(RoundedRectangle(cornerRadius: 22).fill(Color.white))
                        .shadow(color: .black.opacity(0.055), radius: 10, x: 0, y: 5)
                        .padding(.top, 22)
                    }

                    // MARK: Common Triggers (live data)

                    Text(lm.l("Common triggers"))
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(darkText)
                        .padding(.top, 44)

                    ForEach(topTriggers.indices, id: \.self) { i in
                        ProgressTriggerCard(
                            icon:        topTriggers[i].icon,
                            title:       lm.l(topTriggers[i].situation),
                            count:       "\(topTriggers[i].count)",
                            timesLabel:  lm.l("TIMES"),
                            highlighted: i == 0
                        )
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 32)
            }

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }
}


// MARK: - Helpful Row

private struct ProgressHelpfulRow: View {

    let icon: String
    let title: String
    let value: Double
    let percentage: String

    private let blue     = Color(red: 116/255, green: 181/255, blue: 218/255)
    private let darkText = Color(red: 38/255,  green: 45/255,  blue: 55/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {

            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(blue)
                    .frame(width: 28, height: 28)

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(darkText)

                Spacer()

                Text(percentage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(blue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 240/255, green: 241/255, blue: 245/255))
                        .frame(height: 9)

                    Capsule()
                        .fill(blue)
                        .frame(width: geometry.size.width * value, height: 9)
                }
            }
            .frame(height: 9)
        }
        .padding(.bottom, 22)
    }
}


// MARK: - Trigger Card

private struct ProgressTriggerCard: View {

    let icon: String
    let title: String
    let count: String
    let timesLabel: String
    let highlighted: Bool

    private let blue     = Color(red: 116/255, green: 181/255, blue: 218/255)
    private let darkText = Color(red: 38/255,  green: 45/255,  blue: 55/255)

    var body: some View {
        HStack(spacing: 18) {

            ZStack {
                Circle()
                    .fill(Color(red: 239/255, green: 247/255, blue: 254/255))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(blue)
            }

            Text(title)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(darkText)

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text(count)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(darkText)

                Text(timesLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 145/255, green: 152/255, blue: 165/255))
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 92)
        .background(RoundedRectangle(cornerRadius: 21).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 21)
                .stroke(
                    highlighted ? blue.opacity(0.55) : Color.clear,
                    lineWidth: highlighted ? 4 : 0
                )
        )
        .shadow(color: .black.opacity(0.045), radius: 8, x: 0, y: 4)
        .padding(.top, 17)
    }
}


// MARK: - Preview

#Preview {
    ProgressScreenView()
}
