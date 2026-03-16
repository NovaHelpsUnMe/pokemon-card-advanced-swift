import SwiftUI

struct HandSheetView: View {
    let title: String
    let subtitle: String
    let cards: [BattlePokemon]
    let canMakeActive: (BattlePokemon) -> Bool
    let canBench: (BattlePokemon) -> Bool
    let actionSummary: (BattlePokemon) -> String
    let onMakeActive: (BattlePokemon) -> Void
    let onBench: (BattlePokemon) -> Void
    let onInspect: (BattlePokemon) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if cards.isEmpty {
                        Text("No cards available.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(cards) { card in
                                HandCardView(
                                    battlePokemon: card,
                                    canMakeActive: canMakeActive(card),
                                    canBench: canBench(card),
                                    actionSummary: actionSummary(card),
                                    onMakeActive: { onMakeActive(card) },
                                    onBench: { onBench(card) },
                                    onInspect: { onInspect(card) }
                                )
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.97, green: 0.94, blue: 0.86))
        }
    }
}

private struct HandCardView: View {
    let battlePokemon: BattlePokemon
    let canMakeActive: Bool
    let canBench: Bool
    let actionSummary: String
    let onMakeActive: () -> Void
    let onBench: () -> Void
    let onInspect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(battlePokemon.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 78)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

            Text(battlePokemon.name)
                .font(.headline)
                .lineLimit(1)

            Text("\(battlePokemon.maxHP) HP")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(actionSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button("Inspect", action: onInspect)
                .buttonStyle(.bordered)

            Button("Make Active", action: onMakeActive)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(!canMakeActive)

            Button("Move to Bench", action: onBench)
                .buttonStyle(.bordered)
                .disabled(!canBench)
        }
        .frame(maxWidth: .infinity, minHeight: 270, alignment: .topLeading)
        .padding(12)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}
