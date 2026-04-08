import SwiftUI
import SwiftData

/// Habit streak grid showing the last 30 days for each habit.
struct StreaksView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()

            // Ambient glow
            VStack {
                RadialGradient(
                    colors: [Color.orange.opacity(0.07), Color.clear],
                    center: .center, startRadius: 0, endRadius: 280
                )
                .frame(height: 300)
                .blur(radius: 30)
                Spacer()
            }
            .ignoresSafeArea()

            if habits.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        overallStreak
                        ForEach(habits) { habit in
                            HabitStreakGrid(habit: habit)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 130)
                }
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔥 Série")
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.45))
            Text("Streaks")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Overall banner
    private var overallStreak: some View {
        let best = habits.map(\.streak).max() ?? 0
        let total = habits.map(\.completions.count).reduce(0, +)

        return HStack(spacing: 0) {
            // Best streak
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.7), radius: 6)
                    Text("\(best)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Meilleure série")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1, height: 44)

            // Total sessions
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.6), radius: 6)
                    Text("\(total)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Sessions totales")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.22), .white.opacity(0.04)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
        )
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "flame.circle")
                    .font(.system(size: 52))
                    .foregroundColor(.orange.opacity(0.6))
                    .shadow(color: .orange.opacity(0.4), radius: 10)
            }
            Text("Aucune habitude")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            Text("Ajoute ta première habitude pour voir tes séries ici.")
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Per-Habit Streak Grid
struct HabitStreakGrid: View {
    let habit: Habit

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 10)

    /// Last 30 days including today
    private var last30Days: [Date] {
        let cal = Calendar.current
        return (0..<30).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: cal.startOfDay(for: Date()))
        }
    }

    private var completionSet: Set<Date> {
        let cal = Calendar.current
        return Set(habit.completions.map { cal.startOfDay(for: $0.completedAt) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title row
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(0.18))
                        .frame(width: 34, height: 34)
                    Image(systemName: habit.iconName)
                        .font(.system(size: 14))
                        .foregroundColor(habit.color)
                        .shadow(color: habit.color.opacity(0.5), radius: 4)
                }
                Text(habit.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                // Streak badge
                if habit.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.7), radius: 4)
                        Text("\(habit.streak)j")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.orange.opacity(0.12)))
                } else {
                    Text("Aucune série")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }

            // Day labels (first row)
            let days = last30Days
            let done = completionSet

            // Grid 3 rows × 10 cols
            VStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<10, id: \.self) { col in
                            let idx = row * 10 + col
                            if idx < days.count {
                                DayCell(date: days[idx], completed: done.contains(days[idx]), color: habit.color)
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 12) {
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(habit.color)
                        .frame(width: 12, height: 12)
                    Text("Complété")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 12, height: 12)
                    Text("Manqué")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.4))
                }
                Spacer()
                Text("30 derniers jours")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.25))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.03)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 14, y: 5)
        )
    }
}

// MARK: - Single Day Cell
private struct DayCell: View {
    let date: Date
    let completed: Bool
    let color: Color

    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var dayNumber: String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(completed ? color : Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isToday ? Color.white.opacity(0.35) : Color.clear, lineWidth: 1.5)
                )
                .shadow(color: completed ? color.opacity(0.4) : .clear, radius: 4)

            if completed {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text(dayNumber)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color.white.opacity(isToday ? 0.7 : 0.25))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 30)
    }
}
