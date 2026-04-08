import SwiftUI

enum AppTab: CaseIterable {
    case home, streaks, science, settings

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .streaks:  return "flame.fill"
        case .science:  return "sparkles"
        case .settings: return "gearshape.fill"
        }
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .background(glassBackground)
        .padding(.horizontal, 44)
        .padding(.bottom, 12)
        .padding(.top, 8)
    }

    // MARK: - Glass morphism background
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.45), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // Layered shadows — upward white glow + depth
            .shadow(color: .white.opacity(0.18), radius: 18, y: -6)
            .shadow(color: .white.opacity(0.08), radius: 32, y: -12)
            .shadow(color: .black.opacity(0.18), radius: 10, y: -3)
    }
}

// MARK: - Tab Button
private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Selected = red accent, others = white (all glow)
            let isAccent = isSelected
            Image(systemName: tab.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isAccent ? Color.red : Color.white)
                // Core glow
                .shadow(
                    color: isAccent ? .red.opacity(0.70) : .white.opacity(0.55),
                    radius: 5
                )
                // Outer halo
                .shadow(
                    color: isAccent ? .red.opacity(0.35) : .white.opacity(0.25),
                    radius: 14
                )
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
