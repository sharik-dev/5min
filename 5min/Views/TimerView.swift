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
            Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()
            
            // Background Glow
            RadialGradient(
                colors: [habit.color.opacity(0.15), Color.clear],
                center: .center, startRadius: 50, endRadius: 400
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: habit.iconName)
                            .foregroundColor(habit.color)
                            .shadow(color: habit.color.opacity(0.5), radius: 4)
                        Text(habit.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // Circular timer
                ZStack {
                    CircularProgressView(progress: timer.progress, color: habit.color, lineWidth: 18)
                        .frame(width: 300, height: 300)
                        .shadow(color: habit.color.opacity(0.3), radius: 20)

                    VStack(spacing: 8) {
                        Text(timer.formattedTime)
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                            .shadow(color: habit.color.opacity(0.4), radius: 10)
                        
                        Text(NSLocalizedString("minutes_focus", comment: ""))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }

                Spacer()

                // Motivation
                Text(NSLocalizedString("timer_motivation", comment: ""))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)

                Spacer()

                // Controls
                HStack(spacing: 32) {
                    Button { timer.reset() } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }

                    Button {
                        if timer.isRunning { timer.pause() }
                        else { timer.start() }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(habit.color)
                                .frame(width: 88, height: 88)
                                .shadow(color: habit.color.opacity(0.5), radius: 16, x: 0, y: 6)
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white)
                        }
                    }

                    Color.clear.frame(width: 60, height: 60)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            timer.configure(minutes: habit.timerDuration)
        }
        .onChange(of: timer.isFinished) { _, finished in
            if finished {
                completeHabit()
                showCompletion = true
            }
        }
        .sheet(isPresented: $showCompletion) {
            CompletionView(habit: habit) { dismiss() }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(red: 0.07, green: 0.07, blue: 0.09))
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
            // Drag indicator
            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 30)

            Spacer()

            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                    .overlay(Circle().stroke(habit.color.opacity(0.3), lineWidth: 1.5))
                    .shadow(color: habit.color.opacity(0.4), radius: 15)
                Text("🎉").font(.system(size: 70))
            }
            .padding(.bottom, 30)

            Text(NSLocalizedString("completion_title", comment: ""))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text(NSLocalizedString("completion_message", comment: ""))
                .font(.system(size: 16))
                .foregroundColor(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)

            if habit.streak > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.5), radius: 4)
                    Text(String(format: NSLocalizedString("streak_congrats", comment: ""), habit.streak))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(Color.orange.opacity(0.3), lineWidth: 1))
                )
                .padding(.top, 24)
            }

            Spacer()

            VStack(spacing: 16) {
                Button { onDismiss() } label: {
                    Text(NSLocalizedString("stop_here", comment: ""))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(habit.color)
                                .shadow(color: habit.color.opacity(0.5), radius: 12, y: 5)
                        )
                }

                Button { onDismiss() } label: {
                    Text(NSLocalizedString("keep_going", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 44)
        }
    }
}
