import SwiftUI

struct HandSheetView: View {
    @ObservedObject var viewModel: GameViewModel
    var onSelectCard: ((BattlePokemon) -> Void)? = nil
    var onMakeActive: ((BattlePokemon) -> Void)? = nil
    var onMoveToBench: ((BattlePokemon) -> Void)? = nil
    var onAttachEnergy: ((BattlePokemon) -> Void)? = nil

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

            if viewModel.gamePhase == .battle {
                EnergyAttachmentPanel(
                    energyInHand: viewModel.playerBoard.energyHandCount,
                    hasAttachedThisTurn: viewModel.hasPlayerAttachedEnergyThisTurn,
                    isPlayerTurn: viewModel.isPlayerTurn,
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

private struct EnergyAttachmentPanel: View {
    let energyInHand: Int
    let hasAttachedThisTurn: Bool
    let isPlayerTurn: Bool
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
                    .foregroundStyle(hasAttachedThisTurn ? .secondary : .blue)
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

        if !isPlayerTurn {
            return "Energy attachments are only available during your turn."
        }

        if energyInHand == 0 {
            return "You do not have any Basic Energy in hand right now."
        }

        return "Put a Pokemon in play to attach your Basic Energy."
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
