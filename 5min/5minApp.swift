import SwiftUI
import SwiftData

@main
struct First5App: App {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var timerManager = TimerManager()

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(languageManager.refreshID)
                .environmentObject(languageManager)
                .environmentObject(timerManager)
        }
        .modelContainer(for: [Habit.self, HabitCompletion.self])
    }
}
