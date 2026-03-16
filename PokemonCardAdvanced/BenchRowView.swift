import SwiftUI

struct BenchRowView: View {
    let cards: [BattlePokemon]
    let maxSlots: Int
    var selectableCardIDs: Set<UUID> = []
    var onSelectCard: ((BattlePokemon) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bench")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(cards) { card in
                        CompactBenchCardView(
                            battlePokemon: card,
                            isSelectable: selectableCardIDs.contains(card.id),
                            onTap: onSelectCard.map { callback in
                                { callback(card) }
                            }
                        )
                    }

                    ForEach(0..<max(0, maxSlots - cards.count), id: \.self) { _ in
                        EmptyBenchSlotView()
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 1)
            }
        }
    }
}

private struct CompactBenchCardView: View {
    let battlePokemon: BattlePokemon
    var isSelectable: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) {
                    benchCard
                }
                .buttonStyle(.plain)
            } else {
                benchCard
            }
        }
        .accessibilityLabel("\(battlePokemon.name) on bench")
    }

    private var benchCard: some View {
        PokemonCardView(
            title: "Bench",
            battlePokemon: battlePokemon,
            displayStyle: .benchCompact
        )
        .frame(width: 86, height: 118, alignment: .top)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelectable ? Color.blue : Color.clear, lineWidth: 3)
        )
    }
}

private struct EmptyBenchSlotView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Open Bench")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: 86, height: 118)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.black.opacity(0.15))
        )
    }
}
