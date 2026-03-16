import SwiftUI

struct HandSheetView: View {
    @ObservedObject var viewModel: GameViewModel
    var onSelectCard: ((BattleCard) -> Void)? = nil
    var onMakeActive: ((BattleCard) -> Void)? = nil
    var onMoveToBench: ((BattleCard) -> Void)? = nil
    var onAttachEnergy: ((BattlePokemon) -> Void)? = nil
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

            if viewModel.isBattleInProgress {
                EnergyAttachmentPanel(
                    energyInHand: viewModel.playerBoard.energyHandCount,
                    hasAttachedThisTurn: viewModel.hasPlayerAttachedEnergyThisTurn,
                    isPlayerActionPhase: viewModel.isPlayerActionPhase,
                    targets: viewModel.availablePlayerEnergyTargets,
                    canAttachTo: viewModel.canAttachPlayerEnergy(to:),
                    onAttachEnergy: { card in
                        onAttachEnergy?(card)
                    }
                )
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

private struct EnergyAttachmentPanel: View {
    let energyInHand: Int
    let hasAttachedThisTurn: Bool
    let isPlayerActionPhase: Bool
    let targets: [BattlePokemon]
    let canAttachTo: (BattlePokemon) -> Bool
    let onAttachEnergy: (BattlePokemon) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("Basic Energy")
                    .font(.headline)

                Text("x\(energyInHand)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                Text(hasAttachedThisTurn ? "Attachment used" : "1 attachment available")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(hasAttachedThisTurn ? Color.secondary : Color.blue)
            }

            if targets.isEmpty {
                Text(emptyStateMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Attach to a Pokemon in play:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(targets) { card in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("Attached \(card.attachedEnergy) • Attack \(card.attackEnergyCost) • Retreat \(card.retreatCost)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button("Attach") {
                                onAttachEnergy(card)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .disabled(!canAttachTo(card))
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var emptyStateMessage: String {
        if hasAttachedThisTurn {
            return "You already attached a Basic Energy this turn."
        }

        if !isPlayerActionPhase {
            return "Energy attachments are only available during your action phase."
        }

        if energyInHand == 0 {
            return "You do not have any Basic Energy in hand right now."
        }

        return "Put a Pokemon in play to attach your Basic Energy."
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
