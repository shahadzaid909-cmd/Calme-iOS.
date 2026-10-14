import SwiftUI

struct ContentView: View {

    // TabRouter is the single source of truth for which tab is active.
    // Injected into the environment so every AppNavItem can read/write it.
    @State private var router = TabRouter()

    var body: some View {
        ZStack {
            // All three stacks are always alive in the hierarchy (same as TabView).
            // Only the active tab is visible and receives hit-testing.

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
