import SwiftUI
import SwiftData

struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var habit: Habit?

    @State private var title: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColorHex: String = "5E5CE6"

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

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            customHeader
            mainContent
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            createButton
        }
        .onAppear {
            if let h = habit {
                title = h.title
                selectedIcon = h.iconName
                selectedColorHex = h.colorHex
            }
        }
    }

    // MARK: - Header
    private var customHeader: some View {
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Scrollable content
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                previewRow
                nameField
                iconGrid
                colorRow
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 110)
        }
    }

    // MARK: - Preview row
    private var previewRow: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.22))
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(selectedColor.opacity(0.4), lineWidth: 1.5))
                Image(systemName: selectedIcon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedColor)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title.isEmpty ? NSLocalizedString("habit_preview_title", comment: "") : title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(title.isEmpty ? Color.gray : .white)
                Text(NSLocalizedString("no_streak", comment: ""))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.3), value: selectedIcon)
        .animation(.spring(response: 0.3), value: selectedColorHex)
    }

    // MARK: - Name field
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(NSLocalizedString("habit_name", comment: ""))
            TextField(NSLocalizedString("habit_name_placeholder", comment: ""), text: $title)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .tint(selectedColor)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Icon grid
    private var iconGrid: some View {
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
                                .fill(isSelected ? selectedColor.opacity(0.22) : Color.white.opacity(0.07))
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? selectedColor : Color.clear, lineWidth: 2)
                                )
                            Image(systemName: icon)
                                .font(.system(size: 21))
                                .foregroundColor(isSelected ? selectedColor : Color.gray.opacity(0.8))
                                .shadow(color: isSelected ? selectedColor.opacity(0.5) : .clear, radius: 6)
                        }
                        .frame(height: 56)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Color row
    private var colorRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(NSLocalizedString("habit_color", comment: ""))
            HStack(spacing: 10) {
                ForEach(presetColors, id: \.hex) { preset in
                    let isSelected = selectedColorHex == preset.hex
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedColorHex = preset.hex }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(preset.color)
                                .frame(width: 36, height: 36)
                                .shadow(color: isSelected ? preset.color.opacity(0.6) : .clear, radius: 8)
                            if isSelected {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2.5)
                                    .frame(width: 42, height: 42)
                            }
                        }
                        .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                }
            }
        }
    }

    // MARK: - Create / Save button (pinned)
    private var createButton: some View {
        Button { save() } label: {
            Text(isEditing
                 ? NSLocalizedString("save_changes", comment: "")
                 : NSLocalizedString("create_habit", comment: ""))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    Rectangle()
                        .fill(title.isEmpty ? selectedColor.opacity(0.35) : selectedColor)
                        .ignoresSafeArea(edges: .bottom)
                )
        }
        .disabled(title.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: title.isEmpty)
    }

    // MARK: - Helpers
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        if let habit {
            habit.title = title
            habit.iconName = selectedIcon
            habit.colorHex = selectedColorHex
        } else {
            let h = Habit(title: title, iconName: selectedIcon, colorHex: selectedColorHex)
            modelContext.insert(h)
        }
        dismiss()
    }
}
