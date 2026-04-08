import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(habit.color.opacity(0.3), lineWidth: 1))
                Image(systemName: habit.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(habit.color)
                    .shadow(color: habit.color.opacity(0.5), radius: 5)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 5) {
                    if habit.streak > 0 {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.5), radius: 3)
                        Text(String(format: NSLocalizedString("streak_days", comment: ""), habit.streak))
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.45))
                    } else {
                        Text(NSLocalizedString("no_streak", comment: ""))
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.35))
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 11))
                        Text("\(habit.timerDuration)m")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color.white.opacity(0.25))
                }
            }

            Spacer()

            if habit.isCompletedToday {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 42, height: 42)
                        .overlay(Circle().stroke(Color.green.opacity(0.3), lineWidth: 1))
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.5), radius: 5)
                }
            } else {
                Button(action: onStart) {
                    ZStack {
                        Circle()
                            .fill(habit.color)
                            .frame(width: 42, height: 42)
                            .shadow(color: habit.color.opacity(0.5), radius: 10, x: 0, y: 3)
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.18), .white.opacity(0.04)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 14, y: 5)
        )
    }
}
