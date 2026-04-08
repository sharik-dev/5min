import Foundation
import Combine

class TimerManager: ObservableObject {
    static let duration: TimeInterval = 5 * 60

    @Published var timeRemaining: TimeInterval = TimerManager.duration
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = false
    @Published var progress: Double = 0.0

    private var cancellable: AnyCancellable?

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
        timeRemaining = TimerManager.duration
        progress = 0.0
    }

    private func tick() {
        guard timeRemaining > 0 else { finish(); return }
        timeRemaining = max(0, timeRemaining - 0.1)
        progress = 1.0 - (timeRemaining / TimerManager.duration)
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
