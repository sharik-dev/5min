import WidgetKit
import SwiftUI

// MARK: - Shared model (mirrors Habit data via UserDefaults App Group)
struct WidgetHabitData: Codable {
    let title: String
    let iconName: String
    let colorHex: String
    let isCompleted: Bool
}

struct First5Entry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabitData]

    var nextPending: WidgetHabitData? {
        habits.first { !$0.isCompleted }
    }
    var completedCount: Int { habits.filter(\.isCompleted).count }
}

// MARK: - Provider
struct First5Provider: TimelineProvider {
    func placeholder(in context: Context) -> First5Entry {
        First5Entry(date: Date(), habits: [
            WidgetHabitData(title: "Meditation", iconName: "brain.head.profile", colorHex: "5E5CE6", isCompleted: true),
            WidgetHabitData(title: "Reading", iconName: "book.fill", colorHex: "30D158", isCompleted: false),
            WidgetHabitData(title: "Exercise", iconName: "dumbbell.fill", colorHex: "FF9F0A", isCompleted: false)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (First5Entry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<First5Entry>) -> Void) {
        let entry = loadEntry()
        let next = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> First5Entry {
        // Read from shared UserDefaults (App Group: group.com.first5.shared)
        // The main app writes habit data using the same key on each save.
        let defaults = UserDefaults(suiteName: "group.com.first5.shared")
        if let data = defaults?.data(forKey: "widgetHabits"),
           let habits = try? JSONDecoder().decode([WidgetHabitData].self, from: data) {
            return First5Entry(date: Date(), habits: habits)
        }
        return First5Entry(date: Date(), habits: [])
    }
}

// MARK: - Small Widget
struct First5SmallView: View {
    var entry: First5Entry
    @Environment(\.widgetFamily) private var family

    private var accentColor: Color {
        guard let habit = entry.nextPending else { return .green }
        return Color(hex: habit.colorHex) ?? .indigo
    }

    var body: some View {
        ZStack {
            if let next = entry.nextPending {
                VStack(alignment: .leading, spacing: 0) {
                    Image(systemName: next.iconName)
                        .font(.system(size: 26))
                        .foregroundColor(accentColor)

                    Spacer()

                    Text(NSLocalizedString("widget_next", comment: ""))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text(next.title)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(2)
                    Text("5 min")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(accentColor.opacity(0.12)))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(14)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    Text(NSLocalizedString("widget_all_done", comment: ""))
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - Medium Widget
struct First5MediumView: View {
    var entry: First5Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("First5")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(entry.completedCount)/\(entry.habits.count)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            if entry.habits.isEmpty {
                Text(NSLocalizedString("widget_no_habits", comment: ""))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else {
                ForEach(entry.habits.prefix(3), id: \.title) { habit in
                    let color = Color(hex: habit.colorHex) ?? .indigo
                    HStack(spacing: 10) {
                        Image(systemName: habit.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(color)
                            .frame(width: 20)
                        Text(habit.title)
                            .font(.system(size: 13))
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(habit.isCompleted ? .green : .secondary.opacity(0.4))
                    }
                }
            }
        }
        .padding(14)
    }
}

// MARK: - Widget Definitions
struct First5SmallWidget: Widget {
    let kind = "First5SmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: First5Provider()) { entry in
            First5SmallView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("First5")
        .description(NSLocalizedString("widget_small_description", comment: ""))
        .supportedFamilies([.systemSmall])
    }
}

struct First5MediumWidget: Widget {
    let kind = "First5MediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: First5Provider()) { entry in
            First5MediumView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("First5")
        .description(NSLocalizedString("widget_medium_description", comment: ""))
        .supportedFamilies([.systemMedium])
    }
}

// Color extension needed in widget target
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: return nil
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
