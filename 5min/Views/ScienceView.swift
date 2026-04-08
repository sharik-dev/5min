import SwiftUI

private struct ScienceEntry: Identifiable {
    let id = UUID()
    let author: String
    let source: String
    let icon: String
    let color: Color
    let quoteKey: String
    let explanationKey: String
}

struct ScienceView: View {
    private let entries: [ScienceEntry] = [
        ScienceEntry(author: "Bluma Zeigarnik",
                     source: NSLocalizedString("science_zeigarnik_source", comment: ""),
                     icon: "brain.head.profile", color: .purple,
                     quoteKey: "science_zeigarnik_quote",
                     explanationKey: "science_zeigarnik_explanation"),
        ScienceEntry(author: "James Clear",
                     source: "Atomic Habits, 2018",
                     icon: "atom", color: .indigo,
                     quoteKey: "science_clear_quote",
                     explanationKey: "science_clear_explanation"),
        ScienceEntry(author: "Dr. Andrew Huberman",
                     source: "Huberman Lab, 2021",
                     icon: "bolt.fill", color: .yellow,
                     quoteKey: "science_huberman_quote",
                     explanationKey: "science_huberman_explanation"),
        ScienceEntry(author: "BJ Fogg",
                     source: "Tiny Habits, 2019",
                     icon: "leaf.fill", color: .green,
                     quoteKey: "science_fogg_quote",
                     explanationKey: "science_fogg_explanation"),
        ScienceEntry(author: "Dr. Piers Steel",
                     source: NSLocalizedString("science_steel_source", comment: ""),
                     icon: "clock.fill", color: .orange,
                     quoteKey: "science_steel_quote",
                     explanationKey: "science_steel_explanation")
    ]

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()

            VStack {
                RadialGradient(
                    colors: [Color.purple.opacity(0.08), Color.clear],
                    center: .center, startRadius: 0, endRadius: 300
                )
                .frame(height: 320)
                .offset(x: -60)
                .blur(radius: 30)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("science_subtitle", comment: ""))
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.45))
                        Text(NSLocalizedString("science_title", comment: ""))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    IntroCard()

                    ForEach(entries) { ScienceCard(entry: $0) }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }
}

private struct IntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 5)
                Text(NSLocalizedString("why_5min_title", comment: ""))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text(NSLocalizedString("why_5min_body", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.6))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.yellow.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.yellow.opacity(0.15), lineWidth: 1))
        )
    }
}

private struct ScienceCard: View {
    let entry: ScienceEntry
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(entry.color.opacity(0.15))
                        .frame(width: 46, height: 46)
                        .overlay(Circle().stroke(entry.color.opacity(0.3), lineWidth: 1))
                    Image(systemName: entry.icon)
                        .font(.system(size: 18))
                        .foregroundColor(entry.color)
                        .shadow(color: entry.color.opacity(0.5), radius: 4)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.author)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(entry.source)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.45))
                }
                Spacer()
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.4))
            }
            .padding(16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expanded.toggle()
                }
            }

            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 16)

                    HStack(alignment: .top, spacing: 10) {
                        Rectangle()
                            .fill(entry.color)
                            .frame(width: 3)
                            .cornerRadius(2)
                            .shadow(color: entry.color.opacity(0.5), radius: 3)
                        Text("« \(NSLocalizedString(entry.quoteKey, comment: "")) »")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)

                    Text(NSLocalizedString(entry.explanationKey, comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
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
        .clipped()
    }
}
