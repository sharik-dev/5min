import Foundation
import Combine
import ActivityKit

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var progress: Double = 0.0

    private var totalDuration: TimeInterval
    private var cancellable: AnyCancellable?

    // Date-based tracking — accurate after background/foreground cycles
    private var endDate: Date?

    // Live Activity
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

    func configure(minutes: Int) {
        cancellable?.cancel()
        stopLiveActivity()
        isRunning = false
        isFinished = false
        totalDuration = TimeInterval(minutes * 60)
        timeRemaining = totalDuration
        progress = 0.0
        endDate = nil
    }

    func setHabitInfo(name: String, icon: String, colorHex: String) {
        habitName = name
        habitIcon = icon
        habitColorHex = colorHex
    }

    // MARK: - Controls

    func start() {
        guard !isRunning && !isFinished else { return }
        isRunning = true
        // Recalculate endDate each time we (re)start so paused time is correct
        endDate = Date().addingTimeInterval(timeRemaining)

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
        updateLiveActivity(isPaused: true)
    }

    func reset() {
        cancellable?.cancel()
        cancellable = nil
        stopLiveActivity()
        isRunning = false
        isFinished = false
        timeRemaining = totalDuration
        progress = 0.0
        endDate = nil
    }

    // Called from TimerView when the app returns to foreground (scenePhase → active)
    func handleForeground() {
        guard isRunning, let end = endDate else { return }
        if end.timeIntervalSinceNow <= 0 {
            finish()
        }
        // If still running, the next tick() will sync timeRemaining from endDate
    }

    // MARK: - Private

    private func tick() {
        guard let end = endDate else { return }
        let remaining = end.timeIntervalSinceNow
        guard remaining > 0 else { finish(); return }
        timeRemaining = remaining
        progress = 1.0 - (timeRemaining / totalDuration)
    }

    private func finish() {
        cancellable?.cancel()
        cancellable = nil
        isRunning = false
        isFinished = true
        timeRemaining = 0
        progress = 1.0
        endDate = nil
        endLiveActivity()
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
                ? Date().addingTimeInterval(timeRemaining) // safe future date even when paused
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
}
