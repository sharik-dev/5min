import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var timer: TimerManager
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var selectedTab: AppTab = .home

    var body: some View {
        Group {
            switch selectedTab {
            case .home:     HomeView()
            case .streaks:  StreaksView()
            case .science:  ScienceView()
            case .settings: SettingsView()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let habit = timer.currentHabit, timer.shouldShowInAppBanner {
                ActiveTimerBanner(habit: habit) {
                    timer.present(for: habit)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .fullScreenCover(isPresented: timerPresentationBinding) {
            if let habit = timer.currentHabit {
                TimerView(habit: habit)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: timer.shouldShowInAppBanner)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                timer.handleForeground()
            }
        }
        .onChange(of: timer.lastCompletedHabitID) { _, completedID in
            guard let completedID else { return }
            completeHabitIfNeeded(with: completedID)
            timer.clearCompletionFlag()
        }
    }

    private var timerPresentationBinding: Binding<Bool> {
        Binding(
            get: { timer.isDetailPresented && timer.currentHabit != nil },
            set: { isPresented in
                if !isPresented {
                    timer.dismissDetail()
                }
            }
        )
    }

    private func completeHabitIfNeeded(with id: UUID) {
        guard let habit = habits.first(where: { $0.id == id }), !habit.isCompletedToday else { return }
        let completion = HabitCompletion(completedAt: Date())
        completion.habit = habit
        habit.completions.append(completion)
        modelContext.insert(completion)
    }
}

#Preview {
    ContentView()
}
