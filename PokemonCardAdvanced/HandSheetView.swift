import SwiftUI

struct HandSheetView: View {
    @ObservedObject var viewModel: GameViewModel
    var onSelectCard: ((BattlePokemon) -> Void)? = nil
    var onMakeActive: ((BattlePokemon) -> Void)? = nil
    var onMoveToBench: ((BattlePokemon) -> Void)? = nil

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 190), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.playerHandSheetTitle)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(viewModel.playerHandSheetSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if viewModel.playerBoard.hand.isEmpty {
                ContentUnavailableView(
                    "No Cards In Hand",
                    systemImage: "rectangle.stack",
                    description: Text("Draw or progress the battle to see cards here.")
                )
                .frame(maxWidth: .infinity, minHeight: 240)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.playerBoard.hand) { card in
                            HandSheetCardView(
                                battlePokemon: card,
                                actionSummary: viewModel.handCardActionSummary(for: card),
                                canMakeActive: viewModel.canAssignPlayerActive(card),
                                canMoveToBench: viewModel.canBenchPlayerCard(card),
                                onSelect: { onSelectCard?(card) },
                                onMakeActive: { onMakeActive?(card) },
                                onMoveToBench: { onMoveToBench?(card) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemBackground))
        )
    }
}

private struct HandSheetCardView: View {
    let battlePokemon: BattlePokemon
    let actionSummary: String
    let canMakeActive: Bool
    let canMoveToBench: Bool
    let onSelect: () -> Void
    let onMakeActive: () -> Void
    let onMoveToBench: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onSelect) {
                PokemonCardView(title: "Hand", battlePokemon: battlePokemon)
                    .contentShape(RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)

            Text(actionSummary)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if canMakeActive {
                Button("Make Active", action: onMakeActive)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }

            if canMoveToBench {
                Button("Move to Bench", action: onMoveToBench)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
