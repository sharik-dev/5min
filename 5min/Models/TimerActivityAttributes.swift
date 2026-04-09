import ActivityKit
import Foundation

// Shared between the main app target and the widget extension target.
// The widget extension gets this file via an explicit PBXBuildFile entry in project.pbxproj.
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // endDate: when the timer will/would finish (used for auto-counting Text timerInterval)
        var endDate: Date
        var isPaused: Bool
        // snapshot of remaining time captured at the moment of pause
        var pausedSecondsRemaining: Double
    }

    var habitName: String
    var habitIcon: String
    var habitColorHex: String
}
