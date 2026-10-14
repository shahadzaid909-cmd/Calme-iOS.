import SwiftUI

struct SuggestionsScreen: View {

    // MARK: - Colors

    private let backgroundColor = Color(red: 233/255, green: 243/255, blue: 255/255)
    private let textColor       = Color(red: 30/255,  green: 43/255,  blue: 61/255)

    // MARK: - Init (logic unchanged)

    private let quickCheckInput: QuickCheckInput?

    init(input: QuickCheckInput? = nil) {
        quickCheckInput = input

        var sit: Situation = .loudNoise
        if let s = input?.situation {
            switch s {
            case .loudNoise:     sit = .loudNoise
            case .crowdedPlace:  sit = .crowdedPlace
            case .brightLight:   sit = .brightLight
            case .routineChange: sit = .routineChange
            }
        }

        var inten: Intensity = .moderate
        if let i = input?.intensity {
            switch i {
            case .low:      inten = .low
            case .moderate: inten = .moderate
            case .high:     inten = .high
            }
        }

        _selectedSituation = State(initialValue: sit)
        _selectedIntensity  = State(initialValue: inten)
    }

    // MARK: - State

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: AppNavTab = .suggestions
    @State private var selectedSituation: Situation
    @State private var selectedIntensity: Intensity
    @State private var recommendations: [RecommendationResult] = []

    private let recommendationManager = RecommendationManager()

    // MARK: - Situation (unchanged)

    enum Situation: String, CaseIterable {
        case loudNoise     = "loud_noise"
        case crowdedPlace  = "crowded_place"
        case brightLight   = "bright_light"
        case routineChange = "routine_change"
        case unknown       = "unknown"
    }

    // MARK: - Intensity (unchanged)

    enum Intensity: String, CaseIterable {
        case low      = "low"
        case moderate = "moderate"
        case high     = "high"
    }

    // MARK: - Personalized summary (dynamic, localized)

    private var personalizedText: String {
        let lm = LanguageManager.shared
        let isArabic = lm.selectedLanguage == "ar"

        guard !recommendations.isEmpty else {
            return lm.l("Based on your child's needs, we've found the best calming strategies.")
        }
        let first = inlineName(recommendations[0].name)
        if recommendations.count >= 2 {
            let second = inlineName(recommendations[1].name)
            if isArabic {
                return "بناءً على ما ساعد من قبل، ابدأ بـ \(first).\nإذا لزم، جرّب \(second) بعدها."
            }
            return "Based on what helped before, start with \(first).\nIf needed, try \(second) next."
        }
        if isArabic {
            return "بناءً على ما ساعد من قبل، ابدأ بـ \(first)."
        }
        return "Based on what helped before, start with \(first)."
    }

    private func inlineName(_ strategy: String) -> String {
        let lm = LanguageManager.shared
        if lm.selectedLanguage == "ar" {
            switch strategy {
            case "Headphones":          return "السماعات"
            case "Quiet Place":         return "مكان هادئ"
            case "Breathing Technique": return "تقنية التنفس"
            case "Movement":            return "الحركة اللطيفة"
            case "Music":               return "الموسيقى الهادئة"
            case "Deep Pressure":       return "الضغط العميق"
            default:                    return strategy
            }
        }
        switch strategy {
        case "Headphones":          return "headphones"
        case "Quiet Place":         return "a quiet place"
        case "Breathing Technique": return "a breathing technique"
        case "Movement":            return "gentle movement"
        case "Music":               return "quiet music"
        case "Deep Pressure":       return "deep pressure"
        default:                    return strategy.lowercased()
        }
    }

    // MARK: - Body

    var body: some View {

        let lm = LanguageManager.shared

        ZStack(alignment: .bottom) {

            backgroundColor.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Back Button

                    Button { dismiss() } label: {
                        Image(systemName: lm.backChevron)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                            .frame(width: 38, height: 38)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 14)

                    // MARK: Title

                    Text(lm.l("Let's start with\nwhat usually works"))
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(textColor)
                        .lineSpacing(2)
                        .padding(.top, 20)

                    // MARK: Subtitle

                    Text(lm.l("Your little helper for calmer moments"))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 128/255, green: 143/255, blue: 163/255))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 7)

                    // MARK: AI Illustration

                    SuggestionsIllustrationView()
                        .padding(.top, 18)

                    // MARK: Personalized Card

                    SuggestionsPersonalizedCard(text: personalizedText)
                        .padding(.top, 16)

                    // MARK: Recommendation Cards

                    VStack(spacing: 10) {
                        ForEach(recommendations) { result in
                            SuggestionsRecommendationCard(result: result)
                        }
                    }
                    .padding(.top, 18)

                    // MARK: Bottom Info Strip

                    SuggestionsInfoCard()
                        .padding(.top, 14)

                    Color.clear.frame(height: 110)
                }
                .padding(.horizontal, 22)
            }

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
        .onAppear {
            generateRecommendations()
        }
    }

    // MARK: - Situation Display Name (English — stored in FeedbackStore)

    private var situationDisplayName: String {
        switch selectedSituation {
        case .loudNoise:     return "Loud Noise"
        case .crowdedPlace:  return "Crowded Place"
        case .brightLight:   return "Bright Lights"
        case .routineChange: return "Routine Changes"
        case .unknown:       return "Unknown"
        }
    }

    // MARK: - Generate Recommendations (unchanged)

    private func generateRecommendations() {
        FeedbackStore.shared.currentSituation = situationDisplayName
        let items = buildItems()
        let result = recommendationManager.getRecommendations(items: items, k: 6, exclude: ["Water"])
        recommendations = result.isEmpty ? fallbackRecommendations() : result
    }

    // MARK: - Build Items (unchanged)

    private func buildItems() -> [String: Double] {
        var base: [String: Double] = [:]
        switch selectedSituation {
        case .loudNoise:
            base["Headphones"]          = 1.0
            base["Quiet Place"]         = 0.9
            base["Breathing Technique"] = 0.4
        case .crowdedPlace:
            base["Quiet Place"]         = 1.0
            base["Movement"]            = 0.7
            base["Headphones"]          = 0.6
        case .brightLight:
            base["Quiet Place"]         = 0.9
            base["Headphones"]          = 0.5
            base["Breathing Technique"] = 0.5
        case .routineChange:
            base["Breathing Technique"] = 0.8
            base["Movement"]            = 0.6
            base["Music"]               = 0.5
        case .unknown:
            base["Quiet Place"]         = 0.7
            base["Breathing Technique"] = 0.7
            base["Movement"]            = 0.5
        }

        let multiplier: Double
        switch selectedIntensity {
        case .low:      multiplier = 0.7
        case .moderate: multiplier = 1.0
        case .high:     multiplier = 1.4
        }

        let preferred = Set(quickCheckInput?.preferredStrategies ?? [])
        for strategy in preferred where base[strategy] == nil {
            base[strategy] = 0.3
        }

        var items: [String: Double] = [:]
        for (strategy, weight) in base {
            var w = weight * multiplier
            if preferred.contains(strategy) { w += 0.3 }
            w += FeedbackStore.shared.weightAdjustment(for: strategy)
            items[strategy] = max(0.05, w)
        }
        return items
    }

    // MARK: - Fallback Recommendations (unchanged)

    private func fallbackRecommendations() -> [RecommendationResult] {
        let names: [String]
        switch selectedSituation {
        case .loudNoise:
            names = ["Headphones",          "Quiet Place",         "Breathing Technique", "Movement",   "Music",       "Deep Pressure"]
        case .crowdedPlace:
            names = ["Quiet Place",         "Headphones",          "Breathing Technique", "Movement",   "Music",       "Deep Pressure"]
        case .brightLight:
            names = ["Quiet Place",         "Breathing Technique", "Headphones",          "Music",      "Movement",    "Deep Pressure"]
        case .routineChange:
            names = ["Breathing Technique", "Movement",            "Music",               "Quiet Place","Headphones",  "Deep Pressure"]
        case .unknown:
            names = ["Quiet Place",         "Breathing Technique", "Movement",            "Headphones", "Music",       "Deep Pressure"]
        }
        return names.map { RecommendationResult(name: $0, score: 0) }
    }
}


// MARK: - AI Illustration

private struct SuggestionsIllustrationView: View {

    var body: some View {
        Image("calmi")
            .resizable()
            .scaledToFit()
            .frame(height: 130)
            .frame(maxWidth: .infinity)
    }
}


// MARK: - Personalized Card

private struct SuggestionsPersonalizedCard: View {

    let text: String

    private let cardBg    = Color(red: 214/255, green: 234/255, blue: 251/255)
    private let darkText  = Color(red: 30/255,  green: 43/255,  blue: 61/255)
    private let blue      = Color(red: 100/255, green: 168/255, blue: 218/255)
    private let mutedText = Color(red: 125/255, green: 148/255, blue: 175/255)
    private let divider   = Color(red: 193/255, green: 218/255, blue: 241/255)

    var body: some View {
        let lm = LanguageManager.shared
        VStack(alignment: .leading, spacing: 0) {

            HStack(alignment: .center, spacing: 0) {
                Text(lm.l("✨ Personalized for your child"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(blue)

                Spacer()

                Text("AI")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 33/255, green: 48/255, blue: 74/255))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }

            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(darkText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 11)

            Rectangle()
                .fill(divider)
                .frame(height: 1)
                .padding(.top, 14)

            HStack(alignment: .top, spacing: 7) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 155/255, green: 183/255, blue: 211/255))
                    .padding(.top, 1)

                Text(lm.l("Recommendations are based on previous caregiver feedback."))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(mutedText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardBg)
        )
    }
}


// MARK: - Recommendation Card

private struct SuggestionsRecommendationCard: View {

    let result: RecommendationResult

    private let textColor = Color(red: 30/255,  green: 43/255,  blue: 61/255)
    private let descColor = Color(red: 108/255, green: 121/255, blue: 140/255)

    var body: some View {
        NavigationLink {
            destinationView
        } label: {
            HStack(spacing: 14) {

                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(iconBackground)
                        .frame(width: 44, height: 44)

                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconTint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(textColor)

                    Text(cardDescription)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(descColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 196/255, green: 206/255, blue: 216/255))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: Navigation destination (unchanged — uses English name as key)

    @ViewBuilder
    private var destinationView: some View {
        switch result.name {
        case "Headphones":          TryHeadphones()
        case "Quiet Place":         QuietPlaceView()
        case "Breathing Technique": BreathingView()
        case "Movement":            GentleMovement()
        case "Music":               QuietMusic()
        case "Deep Pressure":       DeepPressure()
        default:                    QuietPlaceView()
        }
    }

    // MARK: Display name (localized)

    private var displayName: String {
        let lm = LanguageManager.shared
        switch result.name {
        case "Headphones":          return lm.l("Try Headphones")
        case "Quiet Place":         return lm.l("Move to a Quiet Place")
        case "Breathing Technique": return lm.l("Breathing Technique")
        case "Movement":            return lm.l("Gentle Movement")
        case "Music":               return lm.l("Quiet Music")
        case "Deep Pressure":       return lm.l("Deep Pressure")
        default:                    return result.name
        }
    }

    // MARK: Description (localized)

    private var cardDescription: String {
        let lm = LanguageManager.shared
        switch result.name {
        case "Headphones":          return lm.l("Reduce surrounding sounds if your child is comfortable using them.")
        case "Quiet Place":         return lm.l("Reduce surrounding noise and give your child some space.")
        case "Breathing Technique": return lm.l("A simple breathing exercise to help your child slow down and feel calmer.")
        case "Movement":            return lm.l("Try slow walking or gentle stretching to release extra energy.")
        case "Music":               return lm.l("Play soft, familiar music to create a calm and comfortable environment.")
        case "Deep Pressure":       return lm.l("Use a familiar gentle pressure activity if the child prefers it.")
        default:                    return lm.l("A strategy that may help your child calm down.")
        }
    }

    // MARK: Icon name

    private var iconName: String {
        switch result.name {
        case "Headphones":          return "headphones"
        case "Quiet Place":         return "house.fill"
        case "Breathing Technique": return "leaf.fill"
        case "Movement":            return "figure.walk"
        case "Music":               return "music.note"
        case "Deep Pressure":       return "hand.raised.fill"
        default:                    return "sparkles"
        }
    }

    private var iconBackground: Color {
        switch result.name {
        case "Headphones":          return Color(red: 222/255, green: 240/255, blue: 252/255)
        case "Quiet Place":         return Color(red: 240/255, green: 233/255, blue: 255/255)
        case "Breathing Technique": return Color(red: 229/255, green: 249/255, blue: 236/255)
        case "Movement":            return Color(red: 255/255, green: 243/255, blue: 226/255)
        case "Music":               return Color(red: 255/255, green: 239/255, blue: 231/255)
        case "Deep Pressure":       return Color(red: 233/255, green: 233/255, blue: 255/255)
        default:                    return Color(red: 233/255, green: 243/255, blue: 255/255)
        }
    }

    private var iconTint: Color {
        switch result.name {
        case "Headphones":          return Color(red: 96/255,  green: 162/255, blue: 219/255)
        case "Quiet Place":         return Color(red: 122/255, green: 92/255,  blue: 210/255)
        case "Breathing Technique": return Color(red: 72/255,  green: 178/255, blue: 108/255)
        case "Movement":            return Color(red: 218/255, green: 148/255, blue: 48/255)
        case "Music":               return Color(red: 224/255, green: 112/255, blue: 68/255)
        case "Deep Pressure":       return Color(red: 96/255,  green: 96/255,  blue: 210/255)
        default:                    return Color(red: 113/255, green: 179/255, blue: 221/255)
        }
    }
}


// MARK: - Bottom Info Card

private struct SuggestionsInfoCard: View {

    var body: some View {
        let lm = LanguageManager.shared
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 160/255, green: 185/255, blue: 215/255))
                .padding(.top, 1)

            Text(lm.l("Suggestions are personalized from previous caregiver feedback."))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(red: 128/255, green: 150/255, blue: 175/255))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 222/255, green: 237/255, blue: 251/255))
        )
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        SuggestionsScreen()
    }
}
