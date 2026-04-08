import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var showAddHabit = false
    @State private var habitToEdit: Habit?
    @State private var habitForTimer: Habit?

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return NSLocalizedString("good_morning", comment: "") }
        if h < 18 { return NSLocalizedString("good_afternoon", comment: "") }
        return NSLocalizedString("good_evening", comment: "")
    }

    private var completedCount: Int { habits.filter(\.isCompletedToday).count }
    private var bestStreak: Int { habits.map(\.streak).max() ?? 0 }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    if !habits.isEmpty { progressRow }
                    habitsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 130)
            }
        }
        .sheet(isPresented: $showAddHabit) { HabitFormView() }
        .sheet(item: $habitToEdit) { HabitFormView(habit: $0) }
        .fullScreenCover(item: $habitForTimer) { TimerView(habit: $0) }
    }

    // MARK: Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(greeting)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text("First5")
                    .font(.system(size: 34, weight: .bold))
            }
            Spacer()
            Button { showAddHabit = true } label: {
                ZStack {
                    Circle().fill(Color.indigo).frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: Progress
    private var progressRow: some View {
        HStack(spacing: 12) {
            ProgressCard(value: "\(completedCount)/\(habits.count)",
                         label: NSLocalizedString("completed_today", comment: ""),
                         icon: "checkmark.circle.fill", color: .green)
            ProgressCard(value: "\(bestStreak)",
                         label: NSLocalizedString("best_streak", comment: ""),
                         icon: "flame.fill", color: .orange)
        }
    }

    // MARK: Habits
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if habits.isEmpty {
                emptyState
            } else {
                Text(NSLocalizedString("today_habits", comment: ""))
                    .font(.system(size: 18, weight: .semibold))

                ForEach(habits) { habit in
                    HabitCard(habit: habit) { habitForTimer = habit }
                        .contextMenu {
                            Button { habitToEdit = habit } label: {
                                Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                modelContext.delete(habit)
                            } label: {
                                Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundColor(.indigo.opacity(0.45))
            Text(NSLocalizedString("no_habits_title", comment: ""))
                .font(.system(size: 20, weight: .semibold))
            Text(NSLocalizedString("no_habits_subtitle", comment: ""))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button { showAddHabit = true } label: {
                Text(NSLocalizedString("add_first_habit", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.indigo))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct ProgressCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(value).font(.system(size: 22, weight: .bold))
                Text(label).font(.system(size: 12)).foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.055), radius: 10, x: 0, y: 3)
        )
    }
}
