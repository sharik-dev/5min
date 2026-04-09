import SwiftUI

struct ActiveTimerBanner: View {
    @EnvironmentObject private var timer: TimerManager

    let habit: Habit
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(0.18))
                        .frame(width: 42, height: 42)
                    Image(systemName: habit.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(habit.color)
                        .shadow(color: habit.color.opacity(0.45), radius: 5)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(timer.isRunning ? "Focus in progress" : "Paused")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(timer.formattedTime)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.22), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}
