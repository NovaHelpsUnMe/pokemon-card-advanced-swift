import SwiftUI

struct BenchRowView: View {
    let title: String
    let cards: [BattlePokemon]
    let maxSlots: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Spacer()

                Text("\(cards.count)/\(maxSlots)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
        )
    }
}

private struct CompactBenchCardView: View {
    let battlePokemon: BattlePokemon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(battlePokemon.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .frame(maxWidth: .infinity)

            Text(battlePokemon.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text("HP \(battlePokemon.currentHP)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 86, height: 100, alignment: .topLeading)
        .padding(8)
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct EmptyBenchSlotView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.dashed")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Open")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 86, height: 100)
        .background(Color.white.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(Color.black.opacity(0.1))
        )
    }
}
