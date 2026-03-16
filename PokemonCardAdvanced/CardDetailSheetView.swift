import SwiftUI

struct CardDetailSheetView: View {
    let battlePokemon: BattlePokemon
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PokemonCardView(title: "Card Detail", battlePokemon: battlePokemon)

                    VStack(alignment: .leading, spacing: 14) {
                        detailSection(title: "Card Stats") {
                            DetailRow(label: "Pokemon", value: battlePokemon.name)
                            DetailRow(label: "Type", value: battlePokemon.type)
                            DetailRow(label: "HP", value: "\(battlePokemon.currentHP) / \(battlePokemon.maxHP)")
                            DetailRow(label: "Attached Energy", value: "\(battlePokemon.attachedEnergy)")
                            DetailRow(label: "Attack", value: battlePokemon.attackName)
                            DetailRow(label: "Attack Cost", value: "\(battlePokemon.attackEnergyCost)")
                            DetailRow(label: "Retreat Cost", value: "\(battlePokemon.retreatCost)")
                            DetailRow(label: "Damage", value: "\(battlePokemon.damage)")
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
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .navigationTitle(battlePokemon.name)
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
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
