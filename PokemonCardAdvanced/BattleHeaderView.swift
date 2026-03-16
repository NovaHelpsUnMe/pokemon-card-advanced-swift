import SwiftUI

struct BattleHeaderView: View {
    let title: String
    let deckCount: Int
    let discardCount: Int
    let prizeCount: Int

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            HeaderCountBadge(label: "Deck", value: deckCount)
            HeaderCountBadge(label: "Discard", value: discardCount)
            HeaderCountBadge(label: "Prize", value: prizeCount)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct HeaderCountBadge: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .frame(minWidth: 52)
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
