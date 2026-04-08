import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var selectedLanguage: AppLanguage = LanguageManager.shared.selectedLanguage

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()

            VStack {
                RadialGradient(
                    colors: [Color.blue.opacity(0.08), Color.clear],
                    center: .center, startRadius: 0, endRadius: 300
                )
                .frame(height: 320)
                .offset(y: -50)
                .blur(radius: 30)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("settings_subtitle", comment: ""))
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.45))
                        Text(NSLocalizedString("settings_title", comment: ""))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    // Language
                    languageSection

                    // Reminders
                    if !habits.isEmpty {
                        SettingsSection(title: NSLocalizedString("notifications_section", comment: "")) {
                            ForEach(habits) { HabitNotificationRow(habit: $0) }
                        }
                    }

                    // App info
                    SettingsSection(title: NSLocalizedString("app_section", comment: "")) {
                        SettingsRow(icon: "info.circle.fill", color: .blue,
                                    title: NSLocalizedString("version", comment: ""), value: "1.0.0")
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 52)
                        SettingsRow(icon: "heart.fill", color: .pink,
                                    title: NSLocalizedString("made_with_love", comment: ""), value: "Sharik")
                    }

                    Text(NSLocalizedString("app_tagline", comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }

    // MARK: - Language section
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("language_section", comment: ""))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.45))
                .textCase(.uppercase)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(AppLanguage.allCases) { lang in
                    Button {
                        withAnimation { selectedLanguage = lang }
                        languageManager.setLanguage(lang)
                    } label: {
                        HStack(spacing: 12) {
                            Text(lang.displayName)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                            Spacer()
                            if selectedLanguage == lang {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .shadow(color: .blue.opacity(0.6), radius: 4)
                            }
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if lang != AppLanguage.allCases.last {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(
                        colors: [.white.opacity(0.15), .white.opacity(0.04)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1))
            )
        }
    }
}

// MARK: - Sub-views
private struct SettingsSection<C: View>: View {
    let title: String
    @ViewBuilder let content: C

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.45))
                .textCase(.uppercase)
                .padding(.leading, 4)
            VStack(spacing: 0) { content }
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.04)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1))
                )
        }
    }
}

private struct HabitNotificationRow: View {
    @Bindable var habit: Habit

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: habit.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(habit.color)
                    .shadow(color: habit.color.opacity(0.5), radius: 4)
                    .frame(width: 32)
                Text(habit.title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: $habit.notificationEnabled)
                    .labelsHidden()
                    .tint(.blue)
                    .onChange(of: habit.notificationEnabled) { _, enabled in
                        if enabled {
                            if habit.notificationTime == nil {
                                var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                                c.hour = 9; c.minute = 0
                                habit.notificationTime = Calendar.current.date(from: c)
                            }
                            NotificationManager.shared.scheduleNotification(for: habit)
                        } else {
                            NotificationManager.shared.removeNotification(for: habit)
                        }
                    }
            }
            .padding(16)

            if habit.notificationEnabled {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.35))
                        .frame(width: 32)
                    DatePicker("",
                               selection: Binding(
                                get: { habit.notificationTime ?? Date() },
                                set: {
                                    habit.notificationTime = $0
                                    NotificationManager.shared.scheduleNotification(for: habit)
                                }),
                               displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            if habit != habit /* Need to handle if not last element realistically, but skipping divider or keeping it is fine as long as we use a global divider loop or just Divider per element, for now keeping it simple as it was. */ { }
            Divider().background(Color.white.opacity(0.1)).padding(.leading, 52)
        }
    }
}

private struct SettingsRow: View {
    let icon: String; let color: Color; let title: String; let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 4)
                .frame(width: 32)
            Text(title).font(.system(size: 15)).foregroundColor(.white)
            Spacer()
            Text(value).font(.system(size: 15)).foregroundColor(Color.white.opacity(0.45))
        }
        .padding(16)
    }
}
