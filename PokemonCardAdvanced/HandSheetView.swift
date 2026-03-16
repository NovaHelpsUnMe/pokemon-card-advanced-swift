import SwiftUI

struct HandSheetView: View {
    @ObservedObject var viewModel: GameViewModel
    var onSelectCard: ((BattlePokemon) -> Void)? = nil
    var onMakeActive: ((BattlePokemon) -> Void)? = nil
    var onMoveToBench: ((BattlePokemon) -> Void)? = nil

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 190), spacing: 14, alignment: .top)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.playerHandSheetTitle)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(viewModel.playerHandSheetSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 2)

            if viewModel.playerBoard.hand.isEmpty {
                ContentUnavailableView(
                    "No Cards In Hand",
                    systemImage: "rectangle.stack",
                    description: Text("Draw or progress the battle to see cards here.")
                )
                .frame(maxWidth: .infinity, minHeight: 240)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 18) {
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
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 10)
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
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onSelect) {
                PokemonCardView(title: "Hand", battlePokemon: battlePokemon)
                    .contentShape(RoundedRectangle(cornerRadius: 22))
            }
            .buttonStyle(.plain)

            Text(actionSummary)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if canMakeActive {
                Button("Make Active", action: onMakeActive)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.regular)
            }

            if canMoveToBench {
                Button("Move to Bench", action: onMoveToBench)
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 2)
    }
}
