import SwiftUI

struct ContentView: View {

    @State private var router = TabRouter()

    var body: some View {
        ZStack {
            NavigationStack {
                CalmeView()
            }
            .opacity(router.selectedTab == .suggestions ? 1 : 0)
            .allowsHitTesting(router.selectedTab == .suggestions)

            NavigationStack {
                HistoryScreenView()
            }
            .opacity(router.selectedTab == .history ? 1 : 0)
            .allowsHitTesting(router.selectedTab == .history)

            NavigationStack {
                ProgressScreenView()
            }
            .opacity(router.selectedTab == .progress ? 1 : 0)
            .allowsHitTesting(router.selectedTab == .progress)
        }
        .environment(\.tabRouter, router)
        .environment(\.layoutDirection, LanguageManager.shared.layoutDirection)
    }
}

#Preview {
    ContentView()
}
