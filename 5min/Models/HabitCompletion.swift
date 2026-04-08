import SwiftData
import Foundation

@Model
final class HabitCompletion {
    var id: UUID = UUID()
    var completedAt: Date = Date()
    var habit: Habit?

    init(completedAt: Date = Date()) {
        self.id = UUID()
        self.completedAt = completedAt
    }
}
