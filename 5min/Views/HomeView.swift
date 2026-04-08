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
            // Dark background matching navbar
            Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()

            // Subtle ambient glow
            VStack {
                RadialGradient(
                    colors: [Color.red.opacity(0.08), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
                .frame(height: 320)
                .offset(x: 60)
                .blur(radius: 30)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
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
        .sheet(isPresented: $showAddHabit) {
            AddHabitModal()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(red: 0.07, green: 0.07, blue: 0.09))
        }
        .sheet(item: $habitToEdit) { habit in
            AddHabitModal(habit: habit)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(red: 0.07, green: 0.07, blue: 0.09))
        }
        .fullScreenCover(item: $habitForTimer) { TimerView(habit: $0) }
    }

    // MARK: Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(greeting)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.45))
                Text("First5")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            Button { showAddHabit = true } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(
                                    colors: [.white.opacity(0.45), .white.opacity(0.08)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ), lineWidth: 1)
                        )
                        .shadow(color: .white.opacity(0.12), radius: 10, y: -4)
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.red)
                        .shadow(color: .red.opacity(0.7), radius: 5)
                }
            }
        }
    }

    // MARK: Progress
    private var progressRow: some View {
        HStack(spacing: 12) {
            GlassProgressCard(value: "\(completedCount)/\(habits.count)",
                         label: NSLocalizedString("completed_today", comment: ""),
                         icon: "checkmark.circle.fill", color: .green)
            GlassProgressCard(value: "\(bestStreak)",
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
                    .foregroundColor(.white)

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
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "star.circle")
                    .font(.system(size: 52))
                    .foregroundColor(.red.opacity(0.6))
                    .shadow(color: .red.opacity(0.4), radius: 10)
            }
            Text(NSLocalizedString("no_habits_title", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            Text(NSLocalizedString("no_habits_subtitle", comment: ""))
                .font(.system(size: 15))
                .foregroundColor(Color.white.opacity(0.45))
                .multilineTextAlignment(.center)
            Button { showAddHabit = true } label: {
                Text(NSLocalizedString("add_first_habit", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(Color.red.opacity(0.5), lineWidth: 1))
                    )
                    .shadow(color: .red.opacity(0.25), radius: 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Glass Progress Card
private struct GlassProgressCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.6), radius: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.25), .white.opacity(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
        )
    }
}
