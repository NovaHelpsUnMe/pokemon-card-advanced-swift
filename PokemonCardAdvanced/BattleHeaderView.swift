import SwiftUI

struct BattleHeaderView: View {
    let label: String
    let deckCount: Int
    let discardCount: Int
    let prizeCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            BattleHeaderBadge(label: "Deck", value: deckCount)
            BattleHeaderBadge(label: "Discard", value: discardCount)
            BattleHeaderBadge(label: "Prizes", value: prizeCount)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct BattleHeaderBadge: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(minWidth: 52)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
