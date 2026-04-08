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
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("science_subtitle", comment: ""))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text(NSLocalizedString("science_title", comment: ""))
                            .font(.system(size: 34, weight: .bold))
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
                Image(systemName: "lightbulb.fill").foregroundColor(.yellow)
                Text(NSLocalizedString("why_5min_title", comment: ""))
                    .font(.system(size: 15, weight: .semibold))
            }
            Text(NSLocalizedString("why_5min_body", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.yellow.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1))
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
                    Circle().fill(entry.color.opacity(0.12)).frame(width: 46, height: 46)
                    Image(systemName: entry.icon)
                        .font(.system(size: 18))
                        .foregroundColor(entry.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.author).font(.system(size: 15, weight: .semibold))
                    Text(entry.source).font(.system(size: 12)).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
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
                    Divider().padding(.horizontal, 16)

                    HStack(alignment: .top, spacing: 10) {
                        Rectangle()
                            .fill(entry.color)
                            .frame(width: 3)
                            .cornerRadius(2)
                        Text("« \(NSLocalizedString(entry.quoteKey, comment: "")) »")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .italic()
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)

                    Text(NSLocalizedString(entry.explanationKey, comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.055), radius: 10, x: 0, y: 3)
        )
        .clipped()
    }
}
