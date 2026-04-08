import SwiftUI
import SwiftData

/// Compact modal for adding / editing a habit.
struct AddHabitModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var habit: Habit?

    @State private var title: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColorHex: String = "5E5CE6"
    @State private var timerDuration: Int = 5
    @State private var notificationEnabled: Bool = false
    @State private var notificationTime: Date = {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 9; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }()

    private var selectedColor: Color { Color(hex: selectedColorHex) ?? .indigo }
    private var isEditing: Bool { habit != nil }

    private let icons = [
        "star.fill", "heart.fill", "flame.fill", "bolt.fill", "leaf.fill",
        "dumbbell.fill", "book.fill", "pencil", "music.note", "paintbrush.fill",
        "figure.walk", "bicycle", "moon.fill", "sun.max.fill", "drop.fill",
        "brain.head.profile", "fork.knife", "cup.and.saucer.fill", "laptopcomputer", "headphones"
    ]

    private let presetColors: [(hex: String, color: Color)] = [
        ("5E5CE6", Color(hex: "5E5CE6")!), ("BF5AF2", Color(hex: "BF5AF2")!),
        ("FF375F", Color(hex: "FF375F")!), ("FF3B30", Color(hex: "FF3B30")!),
        ("FF9F0A", Color(hex: "FF9F0A")!), ("FFD60A", Color(hex: "FFD60A")!),
        ("30D158", Color(hex: "30D158")!), ("40C8E0", Color(hex: "40C8E0")!),
        ("64D2FF", Color(hex: "64D2FF")!), ("0A84FF", Color(hex: "0A84FF")!)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)

            modalHeader

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    previewRow
                    nameSection
                    iconSection
                    colorSection
                    timerSection
                    notificationSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) { saveButton }
        .onAppear {
            if let h = habit {
                title = h.title
                selectedIcon = h.iconName
                selectedColorHex = h.colorHex
                timerDuration = h.timerDuration
                notificationEnabled = h.notificationEnabled
                if let t = h.notificationTime { notificationTime = t }
            }
        }
    }

    // MARK: - Header
    private var modalHeader: some View {
        ZStack {
            Text(isEditing
                 ? NSLocalizedString("edit_habit", comment: "")
                 : NSLocalizedString("new_habit", comment: ""))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            HStack {
                Button { dismiss() } label: {
                    Text(NSLocalizedString("cancel", comment: ""))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.10)))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Preview
    private var previewRow: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.18))
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(selectedColor.opacity(0.4), lineWidth: 1.5))
                    .shadow(color: selectedColor.opacity(0.4), radius: 8)
                Image(systemName: selectedIcon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedColor)
                    .shadow(color: selectedColor.opacity(0.6), radius: 5)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title.isEmpty ? NSLocalizedString("habit_preview_title", comment: "") : title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(title.isEmpty ? Color.white.opacity(0.3) : .white)
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.4))
                    Text("\(timerDuration) min")
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.4))
                }
            }
            Spacer()
        }
        .animation(.spring(response: 0.3), value: selectedIcon)
        .animation(.spring(response: 0.3), value: selectedColorHex)
    }

    // MARK: - Name
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(NSLocalizedString("habit_name", comment: ""))
            TextField(NSLocalizedString("habit_name_placeholder", comment: ""), text: $title)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .tint(selectedColor)
                .padding(16)
                .background(glassField)
        }
    }

    // MARK: - Icon grid
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(NSLocalizedString("habit_icon", comment: ""))
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                spacing: 12
            ) {
                ForEach(icons, id: \.self) { icon in
                    let isSelected = selectedIcon == icon
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedIcon = icon }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isSelected ? selectedColor.opacity(0.20) : Color.white.opacity(0.06))
                                .overlay(Circle().stroke(isSelected ? selectedColor : Color.clear, lineWidth: 2))
                                .shadow(color: isSelected ? selectedColor.opacity(0.4) : .clear, radius: 6)
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(isSelected ? selectedColor : Color.white.opacity(0.5))
                                .shadow(color: isSelected ? selectedColor.opacity(0.5) : .clear, radius: 5)
                        }
                        .frame(height: 54)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                }
            }
        }
    }

    // MARK: - Colors
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(NSLocalizedString("habit_color", comment: ""))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.hex) { preset in
                        let isSelected = selectedColorHex == preset.hex
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedColorHex = preset.hex }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(preset.color)
                                    .frame(width: 34, height: 34)
                                    .shadow(color: isSelected ? preset.color.opacity(0.7) : .clear, radius: 8)
                                if isSelected {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2.5)
                                        .frame(width: 40, height: 40)
                                }
                            }
                            .frame(width: 42, height: 42)
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(isSelected ? 1.12 : 1.0)
                        .animation(.spring(response: 0.3), value: isSelected)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Timer Duration
    private var timerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("MINUTEUR")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach([1, 2, 5, 10, 15, 20, 30], id: \.self) { m in
                        let isSelected = timerDuration == m
                        Button {
                            withAnimation(.spring(response: 0.3)) { timerDuration = m }
                        } label: {
                            Text("\(m)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isSelected ? selectedColor : Color.white.opacity(0.5))
                                .frame(width: 50)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isSelected ? selectedColor.opacity(0.18) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.3), value: isSelected)
                    }
                }
                .padding(6)
                .background(glassField)
            }

            Text("minutes")
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.35))
        }
    }

    // MARK: - Notification
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("NOTIFICATION")
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(notificationEnabled ? selectedColor : Color.white.opacity(0.4))
                        .shadow(color: notificationEnabled ? selectedColor.opacity(0.5) : .clear, radius: 5)
                        .frame(width: 28)
                    Text("Rappel quotidien")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $notificationEnabled)
                        .labelsHidden()
                        .tint(selectedColor)
                }
                .padding(16)

                if notificationEnabled {
                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 16)

                    HStack(spacing: 12) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.4))
                            .frame(width: 28)
                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(glassField)
            .animation(.spring(response: 0.35), value: notificationEnabled)
        }
    }

    // MARK: - Save button
    private var saveButton: some View {
        Button { save() } label: {
            Text(isEditing
                 ? NSLocalizedString("save_changes", comment: "")
                 : NSLocalizedString("create_habit", comment: ""))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(title.isEmpty ? Color.white.opacity(0.35) : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    Rectangle()
                        .fill(title.isEmpty ? selectedColor.opacity(0.25) : selectedColor)
                        .shadow(color: title.isEmpty ? .clear : selectedColor.opacity(0.5), radius: 12, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
        }
        .disabled(title.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: title.isEmpty)
    }

    // MARK: - Helpers
    private var glassField: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.white.opacity(0.06))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color.white.opacity(0.35))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        if let habit {
            habit.title = title
            habit.iconName = selectedIcon
            habit.colorHex = selectedColorHex
            habit.timerDuration = timerDuration
            habit.notificationEnabled = notificationEnabled
            habit.notificationTime = notificationEnabled ? notificationTime : nil
            if notificationEnabled {
                NotificationManager.shared.scheduleNotification(for: habit)
            } else {
                NotificationManager.shared.removeNotification(for: habit)
            }
        } else {
            let h = Habit(title: title, iconName: selectedIcon, colorHex: selectedColorHex, timerDuration: timerDuration)
            h.notificationEnabled = notificationEnabled
            h.notificationTime = notificationEnabled ? notificationTime : nil
            modelContext.insert(h)
            if notificationEnabled {
                NotificationManager.shared.scheduleNotification(for: h)
            }
        }
        dismiss()
    }
}
