import SwiftUI
import SwiftData

@main
struct First5App: App {
    @StateObject private var languageManager = LanguageManager.shared

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(languageManager.refreshID)
                .environmentObject(languageManager)
        }
        .modelContainer(for: [Habit.self, HabitCompletion.self])
    }
}
