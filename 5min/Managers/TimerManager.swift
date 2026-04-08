import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var progress: Double = 0.0

    private var totalDuration: TimeInterval
    private var cancellable: AnyCancellable?

    init(minutes: Int = 5) {
        self.totalDuration = TimeInterval(minutes * 60)
        self.timeRemaining = self.totalDuration
    }

    func configure(minutes: Int) {
        cancellable?.cancel()
        isRunning = false
        isFinished = false
        totalDuration = TimeInterval(minutes * 60)
        timeRemaining = totalDuration
        progress = 0.0
    }

    func start() {
        guard !isRunning && !isFinished else { return }
        isRunning = true
        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    func pause() {
        isRunning = false
        cancellable?.cancel()
    }

    func reset() {
        cancellable?.cancel()
        isRunning = false
        isFinished = false
        timeRemaining = totalDuration
        progress = 0.0
    }

    private func tick() {
        guard timeRemaining > 0 else { finish(); return }
        timeRemaining = max(0, timeRemaining - 0.1)
        progress = 1.0 - (timeRemaining / totalDuration)
    }

    private func finish() {
        cancellable?.cancel()
        isRunning = false
        isFinished = true
        timeRemaining = 0
        progress = 1.0
    }

    var formattedTime: String {
        let total = Int(ceil(timeRemaining))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
