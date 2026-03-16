import SwiftUI

enum CardDetailItem: Identifiable {
    case handCard(BattleCard)
    case boardPokemon(BattlePokemon)

    var id: String {
        switch self {
        case .handCard(let card):
            return "hand-\(card.id.uuidString)"
        case .boardPokemon(let pokemon):
            return "board-\(pokemon.id.uuidString)"
        }
    }
}

struct TrainerCardPreview: View {
    let title: String
    let trainer: TrainerCard

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                Text("Trainer")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: trainer.systemImageName)
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(Color.green.opacity(0.92))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.72))
                )

            Text(trainer.name)
                .font(.title2)
                .fontWeight(.bold)

            Text(trainer.effectDescription)
                .font(.headline)

            Text(trainer.trainerDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.green.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct CardDetailSheetView: View {
    let item: CardDetailItem
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    detailCard

                    VStack(alignment: .leading, spacing: 14) {
                        detailContent
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .navigationTitle(detailTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onDismiss {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done", action: onDismiss)
                    }
                }
            }
        }
    }

    private var detailTitle: String {
        switch item {
        case .handCard(let card):
            return card.name
        case .boardPokemon(let pokemon):
            return pokemon.name
        }
    }

    @ViewBuilder
    private var detailCard: some View {
        switch item {
        case .boardPokemon(let pokemon):
            PokemonCardView(title: "Card Detail", battlePokemon: pokemon)
        case .handCard(let card):
            if let pokemon = card.pokemon {
                PokemonCardView(
                    title: "Card Detail",
                    battlePokemon: BattlePokemon(pokemon: pokemon)
                )
            } else if let trainer = card.trainer {
                TrainerCardPreview(title: "Card Detail", trainer: trainer)
            }
        }
    }

    @ViewBuilder
    private var detailContent: some View {
        switch item {
        case .boardPokemon(let pokemon):
            pokemonSections(for: pokemon)
        case .handCard(let card):
            if let pokemon = card.pokemon {
                pokemonDefinitionSections(for: pokemon)
            } else if let trainer = card.trainer {
                trainerSections(for: trainer)
            }
        }
    }

    @ViewBuilder
    private func pokemonSections(for battlePokemon: BattlePokemon) -> some View {
        detailSection(title: "Card Stats") {
            DetailRow(label: "Pokemon", value: battlePokemon.name)
            DetailRow(label: "Stage", value: battlePokemon.stage.rawValue)
            if let evolvesFrom = battlePokemon.evolvesFrom {
                DetailRow(label: "Evolves From", value: evolvesFrom)
            }
            DetailRow(label: "HP", value: "\(battlePokemon.currentHP) / \(battlePokemon.maxHP)")
            DetailRow(label: "Damage Kept", value: "\(battlePokemon.damageTaken)")
            DetailRow(label: "Attached Energy", value: "\(battlePokemon.attachedEnergy)")
            DetailRow(label: "Attack", value: battlePokemon.attackName)
            DetailRow(label: "Attack Cost", value: "\(battlePokemon.attackEnergyCost)")
            DetailRow(label: "Retreat Cost", value: "\(battlePokemon.retreatCost)")
            DetailRow(label: "Damage", value: "\(battlePokemon.damage)")
        }

        if battlePokemon.evolutionLine.count > 1 {
            detailSection(title: "Evolution Line") {
                Text(battlePokemon.evolutionLine.map(\.name).joined(separator: " -> "))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }

        detailSection(title: "Attack Description") {
            Text(battlePokemon.attackDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }

        detailSection(title: "Card Info") {
            Text(battlePokemon.pokemonDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func pokemonDefinitionSections(for pokemon: Pokemon) -> some View {
        detailSection(title: "Card Stats") {
            DetailRow(label: "Pokemon", value: pokemon.name)
            DetailRow(label: "Stage", value: pokemon.stage.rawValue)
            if let evolvesFrom = pokemon.evolvesFrom {
                DetailRow(label: "Evolves From", value: evolvesFrom)
            }
            DetailRow(label: "HP", value: "\(pokemon.maxHP)")
            DetailRow(label: "Attack", value: pokemon.attackName)
            DetailRow(label: "Attack Cost", value: "\(pokemon.attackEnergyCost)")
            DetailRow(label: "Retreat Cost", value: "\(pokemon.retreatCost)")
            DetailRow(label: "Damage", value: "\(pokemon.damage)")
        }

        detailSection(title: "Attack Description") {
            Text(pokemon.attackDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }

        detailSection(title: "Card Info") {
            Text(pokemon.pokemonDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func trainerSections(for trainer: TrainerCard) -> some View {
        detailSection(title: "Trainer Effect") {
            DetailRow(label: "Action", value: trainer.effect.actionLabel)
            DetailRow(label: "Effect", value: trainer.effectDescription)
            DetailRow(label: "Timing", value: "Your action phase")
        }

        detailSection(title: "Card Info") {
            Text(trainer.trainerDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
