import SwiftUI

struct TimerModal: View {
    @EnvironmentObject private var timer: TimerManager
    @State private var showExpandedView = false
    
    var body: some View {
        if timer.isRunning || timer.isFinished {
            VStack(spacing: 0) {
                // Top compact timer bar
                Button(action: { showExpandedView = true }) {
                    HStack(spacing: 12) {
                        // Habit icon with color
                        if let habit = timer.currentHabit {
                            ZStack {
                                Circle()
                                    .fill(habit.color.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: habit.iconName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(habit.color)
                            }
                        }
                        
                        // Habit name
                        if let habit = timer.currentHabit {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Focus Mode")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Spacer()
                        
                        // Timer display
                        Text(timer.formattedTime)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .trailing)
                        
                        // Status indicator
                        Circle()
                            .fill(timer.isRunning ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                
                // Quick controls
                HStack(spacing: 8) {
                    Button(action: { timer.pause() }) {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    
                    Button(action: { timer.reset() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .fullScreenCover(isPresented: $showExpandedView) {
                if let habit = timer.currentHabit {
                    ExpandedTimerView(isPresented: $showExpandedView, habit: habit)
                        .environmentObject(timer)
                }
            }
        }
    }
}

struct ExpandedTimerView: View {
    @EnvironmentObject private var timer: TimerManager
    @Binding var isPresented: Bool
    let habit: Habit
    
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
                        isPresented = false
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
    }
}

#Preview {
    TimerModal()
        .environmentObject(TimerManager())
}
