import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var timer = TimerManager()

    let habit: Habit
    @State private var showCompletion = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [habit.color.opacity(0.18), Color(.systemBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        timer.reset()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(11)
                            .background(Circle().fill(Color(.systemFill)))
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: habit.iconName)
                            .foregroundColor(habit.color)
                        Text(habit.title)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Spacer()
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // Circular timer
                ZStack {
                    CircularProgressView(progress: timer.progress, color: habit.color, lineWidth: 16)
                        .frame(width: 270, height: 270)

                    VStack(spacing: 8) {
                        Text(timer.formattedTime)
                            .font(.system(size: 62, weight: .thin, design: .rounded))
                            .monospacedDigit()
                        Text(NSLocalizedString("minutes_focus", comment: ""))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Motivation
                Text(NSLocalizedString("timer_motivation", comment: ""))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)

                Spacer()

                // Controls
                HStack(spacing: 28) {
                    Button { timer.reset() } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .padding(18)
                            .background(Circle().fill(Color(.systemFill)))
                    }

                    Button {
                        if timer.isRunning { timer.pause() }
                        else { timer.start() }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(habit.color)
                                .frame(width: 84, height: 84)
                                .shadow(color: habit.color.opacity(0.4), radius: 14, x: 0, y: 5)
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                    }

                    Color.clear.frame(width: 56, height: 56)
                }
                .padding(.bottom, 56)
            }
        }
        .onChange(of: timer.isFinished) { _, finished in
            if finished {
                completeHabit()
                showCompletion = true
            }
        }
        .sheet(isPresented: $showCompletion) {
            CompletionView(habit: habit) { dismiss() }
        }
    }

    private func completeHabit() {
        guard !habit.isCompletedToday else { return }
        let c = HabitCompletion(completedAt: Date())
        c.habit = habit
        habit.completions.append(c)
        modelContext.insert(c)
    }
}

// MARK: - Completion Sheet
struct CompletionView: View {
    let habit: Habit
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.12))
                    .frame(width: 130, height: 130)
                Text("🎉").font(.system(size: 64))
            }
            .padding(.bottom, 28)

            Text(NSLocalizedString("completion_title", comment: ""))
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text(NSLocalizedString("completion_message", comment: ""))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            if habit.streak > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill").foregroundColor(.orange)
                    Text(String(format: NSLocalizedString("streak_congrats", comment: ""), habit.streak))
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.orange.opacity(0.11)))
                .padding(.top, 20)
            }

            Spacer()

            VStack(spacing: 14) {
                Button { onDismiss() } label: {
                    Text(NSLocalizedString("stop_here", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 18).fill(habit.color))
                }

                Button { onDismiss() } label: {
                    Text(NSLocalizedString("keep_going", comment: ""))
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 44)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
