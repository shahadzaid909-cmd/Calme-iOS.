import SwiftUI

// MARK: - App Colors

enum AppColors {
    static let background    = Color(red: 233/255, green: 243/255, blue: 255/255)
    static let darkText      = Color(red: 31/255,  green: 43/255,  blue: 60/255)
    static let secondaryText = Color(red: 105/255, green: 116/255, blue: 133/255)
    static let primaryBlue   = Color(red: 113/255, green: 179/255, blue: 221/255)
    static let activeBlue    = Color(red: 0/255,   green: 132/255, blue: 255/255)
    static let selectedTabBg = Color(red: 218/255, green: 239/255, blue: 255/255)
    static let lightBlue     = Color(red: 218/255, green: 235/255, blue: 250/255)
    static let avoidBg       = Color(red: 255/255, green: 240/255, blue: 240/255)
    static let avoidBorder   = Color(red: 250/255, green: 210/255, blue: 210/255)
    static let avoidText     = Color(red: 190/255, green: 45/255,  blue: 45/255)
    static let avoidIcon     = Color(red: 224/255, green: 133/255, blue: 133/255)
}

// MARK: - Nav Tab

enum AppNavTab: Equatable {
    case suggestions
    case history
    case progress
}

// MARK: - Tab Router
// Owned by ContentView; drives which NavigationStack is visible.
// Uses @Observable (Observation framework) to avoid Combine dependency.

@Observable
final class TabRouter {
    var selectedTab: AppNavTab = .suggestions
}

// MARK: - Tab Router Environment Key
// Using an environment key (not @EnvironmentObject) so previews work
// without injecting the router explicitly — the default is used instead.

private struct TabRouterKey: EnvironmentKey {
    static let defaultValue = TabRouter()
}

extension EnvironmentValues {
    var tabRouter: TabRouter {
        get { self[TabRouterKey.self] }
        set { self[TabRouterKey.self] = newValue }
    }
}

// MARK: - Suggestions Grid Icon (4 squares)

struct AppGridIcon: View {

    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) { square; square }
            HStack(spacing: 3) { square; square }
        }
        .frame(width: 23, height: 23)
    }

    private var square: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 10, height: 10)
    }
}

// MARK: - Bottom Navigation Bar

struct AppBottomNavBar: View {

    @Binding var selectedTab: AppNavTab

    var body: some View {
        let lm = LanguageManager.shared
        HStack(spacing: 0) {
            AppNavItem(tab: .suggestions, title: lm.l("Suggestions"), selectedTab: $selectedTab)
            AppNavItem(tab: .history,     title: lm.l("History"),     selectedTab: $selectedTab)
            AppNavItem(tab: .progress,    title: lm.l("Progress"),    selectedTab: $selectedTab)
        }
        .padding(6)
        .frame(height: 64)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 5)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

// MARK: - Nav Item

private struct AppNavItem: View {

    let tab: AppNavTab
    let title: String
    @Binding var selectedTab: AppNavTab
    @Environment(\.tabRouter) private var router

    // isSelected is driven by the global router so it stays correct
    // even when another screen triggers a tab switch.
    private var isSelected: Bool { router.selectedTab == tab }

    var body: some View {
        Button {
            router.selectedTab = tab   // actual navigation at root level
            selectedTab = tab          // keep local binding in sync
        } label: {
            VStack(spacing: 3) {
                Group {
                    switch tab {
                    case .suggestions:
                        AppGridIcon(color: isSelected ? AppColors.activeBlue : .black)
                    case .history:
                        Image(systemName: "clock")
                            .font(.system(size: 20, weight: .medium))
                    case .progress:
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 20, weight: .medium))
                    }
                }
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
            }
            .foregroundColor(isSelected ? AppColors.activeBlue : .black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                if isSelected {
                    Capsule().fill(AppColors.selectedTabBg)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feedback Section ("Did this help?")

struct AppFeedbackSection: View {

    @Binding var feedback: String?

    var body: some View {
        let lm = LanguageManager.shared
        VStack(spacing: 16) {
            Text(lm.l("Did this help?"))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.darkText)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                AppFeedbackButton(title: lm.l("Yes"),      selected: feedback == "Yes")      { feedback = "Yes" }
                AppFeedbackButton(title: lm.l("A little"), selected: feedback == "A little") { feedback = "A little" }
                AppFeedbackButton(title: lm.l("No"),       selected: feedback == "No")       { feedback = "No" }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Check Input
// Shared model passed through QuickCheck → WhatUsuallyHelps → SuggestionsScreen.

struct QuickCheckInput {
    enum Situation { case loudNoise, crowdedPlace, brightLight, routineChange }
    enum Intensity  { case low, moderate, high }

    var situation: Situation
    var intensity:  Intensity
    var preferredStrategies: [String]   // user's multi-select from WhatUsuallyHelps
}

// MARK: - History Entry

struct HistoryEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let strategy: String    // e.g. "Headphones"
    let situation: String   // e.g. "Loud Noise" — set by SuggestionsScreen
    let feedback: String    // "Yes", "A little", "No"
}

// MARK: - Feedback Store
// @Observable so HistoryScreenView and ProgressScreenView auto-update the
// moment feedback is recorded from any detail screen.

@Observable
final class FeedbackStore {
    static let shared = FeedbackStore()

    // Observed by History and Progress screens
    private(set) var entries: [HistoryEntry] = []

    // Set by SuggestionsScreen when recommendations are generated so the
    // detail screen's feedback is tagged with the correct trigger situation.
    var currentSituation: String = "Unknown"

    // Per-strategy accumulated score (for Core ML weight nudging)
    private var scores: [String: Double] = [:]

    private let defaults  = UserDefaults.standard
    private let scoresKey = "calme.strategyFeedback.v1"
    private let historyKey = "calme.feedbackHistory.v1"

    private init() {
        if let s = defaults.dictionary(forKey: scoresKey) as? [String: Double] {
            scores = s
        }
        if let data = defaults.data(forKey: historyKey),
           let loaded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            entries = loaded
        }
    }

    // MARK: - Core ML weight adjustment (unchanged API)

    func weightAdjustment(for strategy: String) -> Double {
        scores[strategy] ?? 0.0
    }

    // MARK: - Record feedback

    func record(strategy: String, feedback: String) {
        let delta: Double
        switch feedback {
        case "Yes":      delta =  0.20
        case "A little": delta =  0.05
        case "No":       delta = -0.15
        default:         return
        }
        scores[strategy] = max(-0.5, min(0.5, (scores[strategy] ?? 0.0) + delta))

        // Prepend so newest appears first in History
        entries.insert(
            HistoryEntry(id: UUID(), date: Date(),
                         strategy: strategy, situation: currentSituation,
                         feedback: feedback),
            at: 0
        )

        defaults.set(scores, forKey: scoresKey)
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: historyKey)
        }
    }

    // MARK: - Progress analytics

    private func successRate(for strategy: String) -> Double {
        let relevant = entries.filter { $0.strategy == strategy }
        guard !relevant.isEmpty else { return 0 }
        let score = relevant.reduce(0.0) {
            $0 + ($1.feedback == "Yes" ? 1.0 : $1.feedback == "A little" ? 0.5 : 0.0)
        }
        return min(1.0, score / Double(relevant.count))
    }

    // All strategies that have at least one entry, sorted best→worst
    var rankedStrategies: [(strategy: String, rate: Double)] {
        Set(entries.map { $0.strategy })
            .map { s in (strategy: s, rate: successRate(for: s)) }
            .sorted { $0.rate > $1.rate }
    }

    // All situations that have appeared, sorted most→least frequent
    var triggerCounts: [(situation: String, count: Int)] {
        var counts: [String: Int] = [:]
        for e in entries { counts[e.situation, default: 0] += 1 }
        return counts.map { (situation: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}


// MARK: - Language Manager
// Single source of truth for the selected UI language; persists to UserDefaults.
// @Observable means any view reading selectedLanguage will re-render on change.

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private let defaults = UserDefaults.standard
    private let key = "calme.selectedLanguage"

    var selectedLanguage: String = "en" {
        didSet { defaults.set(selectedLanguage, forKey: key) }
    }

    var layoutDirection: LayoutDirection {
        selectedLanguage == "ar" ? .rightToLeft : .leftToRight
    }

    private init() {
        selectedLanguage = defaults.string(forKey: key) ?? "en"
    }

    // MARK: - Localization

    // The chevron direction flips in RTL so the back button feels natural.
    var backChevron: String {
        selectedLanguage == "ar" ? "chevron.right" : "chevron.left"
    }

    // Returns the Arabic translation for key, or key itself as the English fallback.
    // Accessing selectedLanguage here registers SwiftUI observation tracking —
    // any view that calls l() in its body will re-render when the language changes.
    func l(_ key: String) -> String {
        guard selectedLanguage == "ar" else { return key }
        return LanguageManager.arabicStrings[key] ?? key
    }

    // MARK: - Arabic Strings Dictionary

    private static let arabicStrings: [String: String] = [

        // MARK: Navigation
        "Suggestions": "اقتراحات",
        "History":     "السجل",
        "Progress":    "التقدم",

        // MARK: Home screen (CalmeView)
        "A calmer moment starts here.":
            "هنا تبدأ لحظات الهدوء",
        "Need a calmer moment?":
            "هل يحتاج طفلك للهدوء؟",
        "Tell us what's happening, and we'll\nhelp you find what works.":
            "أخبرنا بما يحدث\nوسنقترح ما قد يساعد",
        "Get Calming Suggestions":
            "جرّب اقتراحاتنا",
        "What usually helps?":
            "ما الذي يساعد عادةً؟",

        // MARK: Strategy & situation names
        // Used as short labels across all screens — keep them concise.
        "Headphones":          "سماعات",
        "Quiet Place":         "مكان هادئ",
        "Breathing Technique": "تمارين التنفس",
        "Music":               "موسيقى",
        "Deep Pressure":       "الضغط العميق",
        "Movement":            "حركة",
        "Water":               "الماء",
        "Loud Noise":          "أصوات عالية",
        "Bright Lights":       "إضاءة ساطعة",
        "Crowded Place":       "أماكن مزدحمة",
        "Change in Routine":   "تغيُّر الروتين",
        "Routine Changes":     "تغيُّر الروتين",
        "Unknown":             "غير محدد",

        // MARK: Quick Check screen
        "Quick Check":
            "تقييم سريع",
        "What's happening right now?":
            "ماذا يواجه طفلك الآن؟",
        "How intense is it?":
            "ما مدى شدة ذلك؟",
        "A little":  "قليلاً",
        "Moderate":  "متوسط",
        "A lot":     "كثيراً",
        "Continue":  "متابعة",

        // MARK: What Usually Helps screen
        "Select anything that helps your child feel\ncalmer":
            "اختر ما يهدّئ طفلك عادةً",
        "Show Suggestions":
            "اعرض الاقتراحات",

        // MARK: Suggestions screen
        "Let's start with\nwhat usually works":
            "إليك ما قد يساعد\nطفلك الآن",
        "Your little helper for calmer moments":
            "رفيقك لإيجاد الهدوء",
        "✨ Personalized for your child":
            "✨ مُعَدّ خصيصاً لطفلك",
        "Based on your child's needs, we've found the best calming strategies.":
            "رتّبنا هذه الاقتراحات بناءً على ما يناسب طفلك.",
        "Recommendations are based on previous caregiver feedback.":
            "مبنية على تجاربك السابقة معه.",
        "Suggestions are personalized from previous caregiver feedback.":
            "نتعلم من تجاربك لنقترح الأنسب دائماً.",
        "Try Headphones":        "جرّب السماعات",
        "Move to a Quiet Place": "انتقل إلى مكان هادئ",
        "Gentle Movement":       "حركة لطيفة",
        "Quiet Music":           "موسيقى هادئة",
        "Reduce surrounding sounds if your child is comfortable using them.":
            "تساعد على تخفيف الضوضاء إن كان مرتاحاً بها.",
        "Reduce surrounding noise and give your child some space.":
            "ابتعد به عن الضوضاء وأعطه مساحة ليهدأ.",
        "A simple breathing exercise to help your child slow down and feel calmer.":
            "تمرين تنفس بسيط يساعده على الاسترخاء والهدوء.",
        "Try slow walking or gentle stretching to release extra energy.":
            "المشي الهادئ أو التمدد البسيط يساعد على تفريغ التوتر.",
        "Play soft, familiar music to create a calm and comfortable environment.":
            "موسيقى هادئة يحبها تخلق له جواً مريحاً.",
        "Use a familiar gentle pressure activity if the child prefers it.":
            "الضغط الحسي اللطيف يريحه إن كان مرتاحاً به.",
        "A strategy that may help your child calm down.":
            "قد يساعد طفلك على الاسترخاء.",

        // MARK: History screen
        "See what happened and what helped":
            "استعرض ما مررتم به وما نجح",
        "TODAY":           "اليوم",
        "YESTERDAY":       "أمس",
        "Helped":          "نجح معه",
        "Helped a little": "ساعد بعض الشيء",
        "Didn't help":     "لم ينجح",

        // MARK: Progress screen
        "What works for your child":
            "ما ينجح مع طفلك",
        "Based on previous experiences":
            "من تجاربك معه",
        "Most helpful":
            "الأكثر نجاحاً معه",
        "Common triggers":
            "المواقف الأكثر تكراراً",
        "TIMES": "مرة",

        // MARK: Settings screen
        "Settings": "الإعدادات",
        "LANGUAGE": "اللغة",

        // MARK: Shared detail-screen labels
        "RECOMMENDED":    "موصى به",
        "Try this":       "جرّب هذا",
        "Avoid":          "تجنّب",
        "Did this help?": "هل أفاد طفلك؟",
        "Yes": "نعم",
        "No":  "لا",

        // MARK: Headphones screen
        "Offer the headphones calmly.":
            "اعرض عليه السماعات بهدوء.",
        "Let your child choose whether to wear them.":
            "دعه يقرر بنفسه إن أراد وضعها.",
        "Make sure the headphones fit comfortably.":
            "تأكد أنها مريحة على أذنيه.",
        "Move to a quieter place if possible.":
            "إن أمكن، انتقل به إلى مكان أهدأ.",
        "Forcing your child to wear the headphones.":
            "إجباره على وضع السماعات.",
        "Using headphones that feel uncomfortable.":
            "سماعات تضغط على أذنيه أو تزعجه.",
        "Increasing the volume too much.":
            "رفع الصوت بشكل مبالغ فيه.",

        // MARK: Quiet Place screen
        "Move away from loud sounds.":
            "ابتعدا معاً عن مصادر الضوضاء.",
        "Reduce unnecessary talking.":
            "تجنّب الكلام الزائد معه.",
        "Give your child some personal space.":
            "أعطه مساحة كافية ليهدأ.",
        "Wait calmly without forcing interaction.":
            "كن قريباً منه بهدوء دون إجبار.",
        "Asking too many questions.":
            "كثرة الأسئلة عليه.",
        "Forcing eye contact.":
            "إجباره على النظر إليك.",
        "Moving quickly between activities.":
            "الانتقال السريع بين الأنشطة.",

        // MARK: Breathing screen
        "Ask your child to sit comfortably.":
            "اطلب منه الجلوس في وضع مريح.",
        "Breathe in slowly through the nose for 4 seconds.":
            "دعه يشهق ببطء من الأنف لمدة ٤ ثوانٍ.",
        "Hold the breath gently for 4 seconds.":
            "ثم يمسك نفسه بلطف لمدة ٤ ثوانٍ.",
        "Breathe out slowly through the mouth for 4 seconds.":
            "ثم يزفر ببطء من الفم لمدة ٤ ثوانٍ.",
        "Forcing deep or fast breathing.":
            "إجباره على التنفس بعمق أو بسرعة.",
        "Counting out loud if it causes stress.":
            "العد بصوت عالٍ إن أزعجه ذلك.",
        "Continuing if your child feels uncomfortable.":
            "المتابعة إن ظهرت عليه علامات الانزعاج.",

        // MARK: Quiet Music screen
        "Play soft, familiar music.":
            "شغّل موسيقى يحبها وتريحه.",
        "Keep the volume low and comfortable.":
            "اضبط الصوت منخفضاً ومريحاً.",
        "Choose music your child already enjoys.":
            "اختر موسيقى يحبها طفلك.",
        "Reduce other background sounds if possible.":
            "أقلّل الأصوات الأخرى في المكان إن أمكن.",
        "Playing music too loudly.":
            "رفع صوت الموسيقى بشكل مزعج.",
        "Switching songs too often.":
            "تغيير الأغاني كثيراً.",
        "Using unfamiliar or intense sounds.":
            "اختيار موسيقى غير مألوفة له أو صاخبة.",

        // MARK: Gentle Movement screen
        "Invite your child to move at their own pace.":
            "شجّعه على التحرك بوتيرته دون ضغط.",
        "Try slow walking or gentle stretching.":
            "جرّبا معاً المشي الهادئ أو التمدد البسيط.",
        "Keep movements simple and predictable.":
            "تجنّب الحركات المفاجئة أو المعقدة.",
        "Allow breaks whenever needed.":
            "أعطه وقتاً للراحة كلما احتاج.",
        "Forcing your child to move.":
            "إجباره على الحركة.",
        "Using fast or intense movements.":
            "الحركات السريعة أو المبالغ فيها.",
        "Continuing if your child seems overwhelmed.":
            "المتابعة إن بدت عليه علامات الإرهاق.",

        // MARK: Deep Pressure screen
        "Ask your child if they want gentle pressure.":
            "اسأله أولاً إن أراد الضغط اللطيف.",
        "Use a familiar calming pressure activity.":
            "جرّب الضغط الهادئ الذي يريحه.",
        "Keep the pressure gentle and comfortable.":
            "احرص أن يكون الضغط خفيفاً ومريحاً.",
        "Stop if your child seems uncomfortable.":
            "توقّف فوراً إن ظهرت عليه علامات الانزعاج.",
        "Applying pressure without permission.":
            "الضغط عليه دون أخذ موافقته.",
        "Using excessive or uncomfortable pressure.":
            "الضغط الشديد أو غير المريح.",
        "Continuing when your child wants to stop.":
            "التجاهل حين يطلب التوقف."
    ]
}

// MARK: - Feedback Button

struct AppFeedbackButton: View {

    let title: String
    let selected: Bool
    let action: () -> Void

    private let selectedBg   = Color(red: 218/255, green: 237/255, blue: 252/255)
    private let unselectedFg = Color(red: 48/255,  green: 57/255,  blue: 72/255)

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selected ? AppColors.activeBlue : unselectedFg)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(selected ? selectedBg : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            selected ? AppColors.activeBlue.opacity(0.45) : Color.clear,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }
}
