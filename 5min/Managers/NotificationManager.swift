import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private let activeTimerIdentifier = "active-focus-session"

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleNotification(for habit: Habit) {
        guard habit.notificationEnabled, let time = habit.notificationTime else { return }
        removeNotification(for: habit)

        let content = UNMutableNotificationContent()
        content.title = "First5"
        content.body = String(format: NSLocalizedString("notification_body", comment: ""), habit.title)
        content.sound = .default

        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func removeNotification(for habit: Habit) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }

    func scheduleTimerCompletion(title: String, seconds: TimeInterval) {
        guard seconds > 0 else { return }
        cancelTimerCompletion()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = NSLocalizedString("completion_message", comment: "")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, seconds),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: activeTimerIdentifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelTimerCompletion() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [activeTimerIdentifier])
    }
}
