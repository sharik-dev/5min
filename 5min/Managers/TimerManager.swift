import Foundation
import Combine
import ActivityKit

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var progress: Double = 0.0
    @Published var currentHabit: Habit?
    @Published var isDetailPresented: Bool = false
    @Published var lastCompletedHabitID: UUID?

    private var totalDuration: TimeInterval
    private var cancellable: AnyCancellable?
    private var endDate: Date?

    private var activity: Activity<TimerActivityAttributes>?
    private var habitName: String = ""
    private var habitIcon: String = ""
    private var habitColorHex: String = "5E5CE6"

    init(minutes: Int = 5) {
        self.totalDuration = TimeInterval(minutes * 60)
        self.timeRemaining = self.totalDuration
    }

    deinit {
        if let act = activity {
            Task.detached { await act.end(dismissalPolicy: .immediate) }
        }
    }

    // MARK: - Configuration

    func configure(minutes: Int, habit: Habit? = nil) {
        cancellable?.cancel()
        cancellable = nil
        stopLiveActivity()
        NotificationManager.shared.cancelTimerCompletion()

        isRunning = false
        isFinished = false
        totalDuration = TimeInterval(minutes * 60)
        timeRemaining = totalDuration
        progress = 0.0
        endDate = nil
        currentHabit = habit
        lastCompletedHabitID = nil

        if let habit {
            setHabitInfo(name: habit.title, icon: habit.iconName, colorHex: habit.colorHex)
        } else {
            habitName = ""
            habitIcon = ""
            habitColorHex = "5E5CE6"
        }
    }

    func present(for habit: Habit) {
        let isSameHabit = currentHabit?.id == habit.id
        if !isSameHabit {
            configure(minutes: habit.timerDuration, habit: habit)
        } else {
            currentHabit = habit
            setHabitInfo(name: habit.title, icon: habit.iconName, colorHex: habit.colorHex)
        }
        isDetailPresented = true
    }

    func dismissDetail() {
        isDetailPresented = false
    }

    func setHabitInfo(name: String, icon: String, colorHex: String) {
        habitName = name
        habitIcon = icon
        habitColorHex = colorHex
    }

    func clearCompletionFlag() {
        lastCompletedHabitID = nil
    }

    // MARK: - Controls

    func start() {
        guard currentHabit != nil, !isRunning && !isFinished else { return }

        isRunning = true
        endDate = Date().addingTimeInterval(timeRemaining)
        NotificationManager.shared.scheduleTimerCompletion(
            title: habitName.isEmpty ? "First5" : habitName,
            seconds: timeRemaining
        )

        if activity != nil {
            updateLiveActivity(isPaused: false)
        } else {
            startLiveActivity()
        }

        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        cancellable?.cancel()
        cancellable = nil
        NotificationManager.shared.cancelTimerCompletion()
        updateLiveActivity(isPaused: true)
    }

    func reset() {
        guard let habit = currentHabit else {
            configure(minutes: Int(totalDuration / 60))
            isDetailPresented = false
            return
        }

        configure(minutes: habit.timerDuration, habit: nil)
        currentHabit = nil
        isDetailPresented = false
    }

    func handleForeground() {
        guard isRunning, let end = endDate else { return }
        if end.timeIntervalSinceNow <= 0 {
            finish()
        }
    }

    // MARK: - Private

    private func tick() {
        guard let end = endDate else { return }
        let remaining = end.timeIntervalSinceNow
        guard remaining > 0 else {
            finish()
            return
        }

        timeRemaining = remaining
        progress = 1.0 - (timeRemaining / totalDuration)
    }

    private func finish() {
        let completedHabitID = currentHabit?.id

        cancellable?.cancel()
        cancellable = nil
        isRunning = false
        isFinished = true
        timeRemaining = 0
        progress = 1.0
        endDate = nil
        NotificationManager.shared.cancelTimerCompletion()
        endLiveActivity()

        lastCompletedHabitID = completedHabitID
        isDetailPresented = false
        currentHabit = nil
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled,
              let end = endDate else { return }

        let attributes = TimerActivityAttributes(
            habitName: habitName,
            habitIcon: habitIcon,
            habitColorHex: habitColorHex
        )
        let state = TimerActivityAttributes.ContentState(
            endDate: end,
            isPaused: false,
            pausedSecondsRemaining: timeRemaining
        )
        let content = ActivityContent(state: state, staleDate: end.addingTimeInterval(300))

        do {
            activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            print("[TimerManager] Live Activity error: \(error)")
        }
    }

    private func updateLiveActivity(isPaused: Bool) {
        guard let act = activity else { return }
        let state = TimerActivityAttributes.ContentState(
            endDate: isPaused
                ? Date().addingTimeInterval(timeRemaining)
                : (endDate ?? Date().addingTimeInterval(timeRemaining)),
            isPaused: isPaused,
            pausedSecondsRemaining: timeRemaining
        )
        let content = ActivityContent(state: state, staleDate: nil)
        Task { await act.update(content) }
    }

    private func endLiveActivity() {
        guard let act = activity else { return }
        activity = nil
        let state = TimerActivityAttributes.ContentState(
            endDate: Date(),
            isPaused: false,
            pausedSecondsRemaining: 0
        )
        let content = ActivityContent(state: state, staleDate: nil)
        Task { await act.end(content, dismissalPolicy: .after(Date().addingTimeInterval(4))) }
    }

    private func stopLiveActivity() {
        guard let act = activity else { return }
        activity = nil
        Task { await act.end(dismissalPolicy: .immediate) }
    }

    // MARK: - Helpers

    var formattedTime: String {
        let total = Int(ceil(timeRemaining))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    var hasActiveSession: Bool {
        guard currentHabit != nil else { return false }
        return isRunning || timeRemaining < totalDuration || progress > 0
    }

    var shouldShowInAppBanner: Bool {
        hasActiveSession && !isDetailPresented
    }
}
