import SwiftUI

struct HistoryScreenView: View {

    @State private var selectedTab: AppNavTab = .history

    private let backgroundColor = Color(red: 232/255, green: 243/255, blue: 255/255)
    private let darkText        = Color(red: 36/255,  green: 43/255,  blue: 53/255)
    private let secondaryText   = Color(red: 105/255, green: 116/255, blue: 133/255)
    private let blue            = Color(red: 116/255, green: 181/255, blue: 218/255)
    private let timelineBlue    = Color(red: 224/255, green: 237/255, blue: 249/255)

    private let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    // MARK: - Grouped entries (newest section first, locale-aware date headers)

    private var groupedEntries: [(title: String, entries: [HistoryEntry])] {
        let lm = LanguageManager.shared
        let store = FeedbackStore.shared
        guard !store.entries.isEmpty else { return [] }

        let cal = Calendar.current
        let today     = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        var sections:  [(day: Date, entries: [HistoryEntry])] = []
        var dayIndex:  [Date: Int] = [:]

        for entry in store.entries {
            let day = cal.startOfDay(for: entry.date)
            if let idx = dayIndex[day] {
                sections[idx].entries.append(entry)
            } else {
                dayIndex[day] = sections.count
                sections.append((day: day, entries: [entry]))
            }
        }

        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "EEE, d MMM"
        dateFmt.locale = lm.selectedLanguage == "ar" ? Locale(identifier: "ar") : Locale(identifier: "en_US")

        return sections.map { s in
            let title: String
            if      s.day == today     { title = lm.l("TODAY") }
            else if s.day == yesterday { title = lm.l("YESTERDAY") }
            else                       { title = dateFmt.string(from: s.day).uppercased() }
            return (title: title, entries: s.entries)
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

                    Text(lm.l("History"))
                        .font(.system(size: 29, weight: .bold))
                        .foregroundColor(darkText)
                        .tracking(-0.6)
                        .padding(.top, 45)

                    Text(lm.l("See what happened and what helped"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(secondaryText)
                        .padding(.top, 3)

                    // MARK: Timeline (live data)

                    ForEach(groupedEntries.indices, id: \.self) { i in
                        let section = groupedEntries[i]

                        HistorySectionTitle(title: section.title)
                            .padding(.top, i == 0 ? 49 : 30)

                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(timelineBlue)
                                .frame(width: 2)
                                .padding(.leading, 17)
                                .padding(.top, 9)
                                .padding(.bottom, 9)

                            VStack(alignment: .leading, spacing: 36) {
                                ForEach(section.entries) { entry in
                                    HistoryTimelineItem(
                                        time:        timeFmt.string(from: entry.date),
                                        status:      statusText(for: entry.feedback),
                                        statusType:  entry.feedback == "Yes" ? .helped : .helpedLittle,
                                        trigger:     lm.l(entry.situation),
                                        triggerIcon: situationIcon(for: entry.situation),
                                        action:      lm.l(entry.strategy),
                                        actionType:  actionType(for: entry.strategy)
                                    )
                                }
                            }
                        }
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 26)
            }

            AppBottomNavBar(selectedTab: $selectedTab)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }

    // MARK: - Helpers

    private func statusText(for feedback: String) -> String {
        let lm = LanguageManager.shared
        switch feedback {
        case "Yes":      return lm.l("Helped")
        case "A little": return lm.l("Helped a little")
        default:         return lm.l("Didn't help")
        }
    }

    private func situationIcon(for situation: String) -> String {
        switch situation {
        case "Loud Noise":      return "speaker.wave.3.fill"
        case "Crowded Place":   return "person.3.fill"
        case "Bright Lights":   return "sun.max.fill"
        case "Routine Changes": return "shuffle"
        default:                return "questionmark.circle"
        }
    }

    private func actionType(for strategy: String) -> HistoryTimelineItem.ActionType {
        switch strategy {
        case "Headphones":          return .headphones
        case "Quiet Place":         return .quietPlace
        case "Breathing Technique": return .breathing
        case "Music":               return .music
        case "Movement":            return .movement
        case "Deep Pressure":       return .deepPressure
        case "Water":               return .water
        default:                    return .headphones
        }
    }
}


// MARK: - Section Title

private struct HistorySectionTitle: View {

    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .tracking(1.2)
            .foregroundColor(Color(red: 145/255, green: 154/255, blue: 168/255))
    }
}


// MARK: - Timeline Item

private struct HistoryTimelineItem: View {

    enum StatusType { case helped, helpedLittle }
    enum ActionType  { case quietPlace, headphones, breathing, music, movement, deepPressure, water }

    let time: String
    let status: String
    let statusType: StatusType
    let trigger: String
    let triggerIcon: String
    let action: String
    let actionType: ActionType

    private let blue     = Color(red: 116/255, green: 181/255, blue: 218/255)
    private let darkText = Color(red: 43/255,  green: 50/255,  blue: 61/255)
    private let gray     = Color(red: 108/255, green: 117/255, blue: 132/255)

    var body: some View {
        HStack(alignment: .top, spacing: 0) {

            ZStack {
                Circle().fill(Color.white).frame(width: 20, height: 20)
                Circle().fill(blue).frame(width: 7, height: 7)
            }
            .frame(width: 34)

            VStack(alignment: .leading, spacing: 13) {

                HStack(alignment: .center) {
                    Text(time)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(darkText)

                    Spacer()

                    HistoryStatusBadge(text: status, type: statusType)
                }

                VStack(alignment: .leading, spacing: 14) {

                    HStack(spacing: 10) {
                        Image(systemName: triggerIcon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(gray)
                            .frame(width: 18)

                        Text(trigger)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(red: 69/255, green: 77/255, blue: 90/255))
                    }

                    HStack(spacing: 8) {
                        Text("→")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color(red: 194/255, green: 201/255, blue: 210/255))

                        HistoryActionIcon(type: actionType, color: blue)

                        Text(action)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(blue)
                    }
                }
                .padding(.horizontal, 17)
                .padding(.vertical, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 21).fill(Color.white))
                .shadow(color: .black.opacity(0.055), radius: 9, x: 0, y: 5)
            }
        }
    }
}


// MARK: - Status Badge

private struct HistoryStatusBadge: View {

    let text: String
    let type: HistoryTimelineItem.StatusType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(
            type == .helped
            ? Color(red: 21/255,  green: 191/255, blue: 91/255)
            : Color(red: 255/255, green: 121/255, blue: 21/255)
        )
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(
                type == .helped
                ? Color(red: 236/255, green: 253/255, blue: 242/255)
                : Color(red: 255/255, green: 247/255, blue: 235/255)
            )
        )
    }
}


// MARK: - Action Icon

private struct HistoryActionIcon: View {

    let type: HistoryTimelineItem.ActionType
    let color: Color

    var body: some View {
        ZStack {
            switch type {
            case .quietPlace:
                ZStack {
                    Image(systemName: "house")
                        .font(.system(size: 23, weight: .medium))

                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .overlay {
                            Text("!")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 9, y: 8)
                }

            case .headphones:
                Image(systemName: "headphones")
                    .font(.system(size: 22, weight: .medium))

            case .breathing:
                Image(systemName: "leaf")
                    .font(.system(size: 23, weight: .medium))

            case .music:
                Image(systemName: "music.note")
                    .font(.system(size: 22, weight: .medium))

            case .movement:
                Image(systemName: "figure.walk")
                    .font(.system(size: 22, weight: .medium))

            case .deepPressure:
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 22, weight: .medium))

            case .water:
                Image(systemName: "drop.fill")
                    .font(.system(size: 22, weight: .medium))
            }
        }
        .foregroundColor(color)
        .frame(width: 24, height: 24)
    }
}


// MARK: - Preview

#Preview {
    HistoryScreenView()
}
