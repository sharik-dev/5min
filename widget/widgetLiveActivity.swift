import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Color helper (mirrors Color+Hex from main target)

private extension Color {
    init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: return nil
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

private func habitColor(_ hex: String) -> Color {
    Color(hexString: hex) ?? Color(red: 0.37, green: 0.36, blue: 0.90)
}

private func formatPausedTime(_ seconds: Double) -> String {
    let total = Int(ceil(max(0, seconds)))
    return String(format: "%02d:%02d", total / 60, total % 60)
}

// MARK: - Widget

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            TimerBannerView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded — shown when user long-presses the compact island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: context.attributes.habitIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(habitColor(context.attributes.habitColorHex))
                        Text(context.attributes.habitName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Group {
                        if context.state.isPaused {
                            Text(formatPausedTime(context.state.pausedSecondsRemaining))
                        } else {
                            Text(
                                timerInterval: Date.now...max(Date.now.addingTimeInterval(1), context.state.endDate),
                                countsDown: true
                            )
                        }
                    }
                    .font(.system(size: 30, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 6) {
                        Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(context.state.isPaused ? "Paused" : "Focus in progress")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                }
            } compactLeading: {
                Image(systemName: context.attributes.habitIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(habitColor(context.attributes.habitColorHex))
            } compactTrailing: {
                Group {
                    if context.state.isPaused {
                        Text(formatPausedTime(context.state.pausedSecondsRemaining))
                    } else {
                        Text(
                            timerInterval: Date.now...max(Date.now.addingTimeInterval(1), context.state.endDate),
                            countsDown: true
                        )
                    }
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
            } minimal: {
                Image(systemName: context.attributes.habitIcon)
                    .font(.system(size: 12))
                    .foregroundStyle(habitColor(context.attributes.habitColorHex))
            }
            .keylineTint(habitColor(context.attributes.habitColorHex))
        }
    }
}

// MARK: - Lock screen / notification banner view

struct TimerBannerView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    private var accent: Color { habitColor(context.attributes.habitColorHex) }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: context.attributes.habitIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.habitName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text(context.state.isPaused ? "Paused" : "Focus in progress")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            Group {
                if context.state.isPaused {
                    Text(formatPausedTime(context.state.pausedSecondsRemaining))
                } else {
                    Text(
                        timerInterval: Date.now...max(Date.now.addingTimeInterval(1), context.state.endDate),
                        countsDown: true
                    )
                }
            }
            .font(.system(size: 38, weight: .thin, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .activityBackgroundTint(Color(red: 0.10, green: 0.10, blue: 0.12))
        .activitySystemActionForegroundColor(.white)
    }
}
