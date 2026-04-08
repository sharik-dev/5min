import SwiftData
import SwiftUI
import Foundation

@Model
final class Habit {
    var id: UUID = UUID()
    var title: String = ""
    var iconName: String = "star.fill"
    var colorHex: String = "5E5CE6"
    var notificationTime: Date?
    var notificationEnabled: Bool = false
    var timerDuration: Int = 5  // minutes
    var createdAt: Date = Date()
    @Relationship(deleteRule: .cascade) var completions: [HabitCompletion] = []

    init(title: String, iconName: String, colorHex: String, timerDuration: Int = 5) {
        self.id = UUID()
        self.title = title
        self.iconName = iconName
        self.colorHex = colorHex
        self.notificationEnabled = false
        self.timerDuration = timerDuration
        self.createdAt = Date()
        self.completions = []
    }

    var streak: Int {
        let calendar = Calendar.current
        let completionDays = Set(completions.map { calendar.startOfDay(for: $0.completedAt) })
        var sortedDays = completionDays.sorted(by: >)
        guard !sortedDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        guard sortedDays[0] == today || sortedDays[0] == yesterday else { return 0 }

        var current = sortedDays.removeFirst()
        var count = 1
        for day in sortedDays {
            if day == calendar.date(byAdding: .day, value: -1, to: current)! {
                count += 1
                current = day
            } else { break }
        }
        return count
    }

    var isCompletedToday: Bool {
        completions.contains { Calendar.current.isDateInToday($0.completedAt) }
    }

    var color: Color {
        Color(hex: colorHex) ?? .indigo
    }
}
