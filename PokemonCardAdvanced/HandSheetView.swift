import SwiftUI

struct HandSheetView: View {
    @ObservedObject var viewModel: GameViewModel
    var onSelectCard: ((BattleCard) -> Void)? = nil
    var onMakeActive: ((BattleCard) -> Void)? = nil
    var onMoveToBench: ((BattleCard) -> Void)? = nil
    var onEvolve: ((BattleCard, BattlePokemon) -> Void)? = nil
    var onPlayTrainer: ((BattleCard) -> Void)? = nil

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
                                battleCard: card,
                                actionSummary: viewModel.handCardActionSummary(for: card),
                                canMakeActive: viewModel.canAssignPlayerActive(card),
                                canMoveToBench: viewModel.canBenchPlayerCard(card),
                                activeEvolutionTarget: viewModel.playerActiveEvolutionTarget(for: card),
                                benchEvolutionTargets: viewModel.playerBenchEvolutionTargets(for: card),
                                trainerButtonTitle: viewModel.canPlayTrainer(card) ? viewModel.trainerButtonTitle(for: card) : nil,
                                onSelect: { onSelectCard?(card) },
                                onMakeActive: { onMakeActive?(card) },
                                onMoveToBench: { onMoveToBench?(card) },
                                onEvolve: { target in onEvolve?(card, target) },
                                onPlayTrainer: { onPlayTrainer?(card) }
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
    let battleCard: BattleCard
    let actionSummary: String
    let canMakeActive: Bool
    let canMoveToBench: Bool
    let activeEvolutionTarget: BattlePokemon?
    let benchEvolutionTargets: [BattlePokemon]
    let trainerButtonTitle: String?
    let onSelect: () -> Void
    let onMakeActive: () -> Void
    let onMoveToBench: () -> Void
    let onEvolve: (BattlePokemon) -> Void
    let onPlayTrainer: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onSelect) {
                previewCard
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

            if let activeEvolutionTarget {
                Button("Evolve \(activeEvolutionTarget.name)", action: {
                    onEvolve(activeEvolutionTarget)
                })
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.regular)
            }

            ForEach(benchEvolutionTargets) { target in
                Button("Evolve \(target.name)", action: {
                    onEvolve(target)
                })
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }

            if let trainerButtonTitle {
                Button(trainerButtonTitle, action: onPlayTrainer)
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 2)
    }

    @ViewBuilder
    private var previewCard: some View {
        if let pokemon = battleCard.pokemon {
            PokemonCardView(
                title: "Hand",
                battlePokemon: BattlePokemon(pokemon: pokemon)
            )
        } else if let trainer = battleCard.trainer {
            TrainerCardPreview(title: "Hand", trainer: trainer)
        }
    }
}
