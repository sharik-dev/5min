import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.14))
                    .frame(width: 52, height: 52)
                Image(systemName: habit.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(habit.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                HStack(spacing: 5) {
                    if habit.streak > 0 {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text(String(format: NSLocalizedString("streak_days", comment: ""), habit.streak))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        Text(NSLocalizedString("no_streak", comment: ""))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            if habit.isCompletedToday {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.13))
                        .frame(width: 42, height: 42)
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                }
            } else {
                Button(action: onStart) {
                    ZStack {
                        Circle()
                            .fill(habit.color)
                            .frame(width: 42, height: 42)
                            .shadow(color: habit.color.opacity(0.35), radius: 8, x: 0, y: 3)
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
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.055), radius: 10, x: 0, y: 3)
        )
    }
}
