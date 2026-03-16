import SwiftUI

struct BenchRowView: View {
    let cards: [BattlePokemon]
    let maxSlots: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bench")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cards) { card in
                        CompactBenchCardView(battlePokemon: card)
                    }

                    ForEach(0..<max(0, maxSlots - cards.count), id: \.self) { _ in
                        EmptyBenchSlotView()
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct CompactBenchCardView: View {
    let battlePokemon: BattlePokemon

    var body: some View {
        PokemonCardView(title: "Bench", battlePokemon: battlePokemon)
            .frame(width: 136, height: 188, alignment: .top)
            .scaleEffect(x: 0.68, y: 0.68, anchor: .topLeading)
            .frame(width: 94, height: 128, alignment: .topLeading)
            .clipped()
            .accessibilityLabel("\(battlePokemon.name) on bench")
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
        .frame(width: 94, height: 128)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.black.opacity(0.15))
        )
    }
}
