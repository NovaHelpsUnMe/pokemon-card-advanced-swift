import SwiftUI

struct CardDetailSheetView: View {
    let battlePokemon: BattlePokemon
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PokemonCardView(title: "Card Detail", battlePokemon: battlePokemon)

                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(label: "Pokemon", value: battlePokemon.name)
                        DetailRow(label: "Type", value: battlePokemon.type)
                        DetailRow(label: "HP", value: "\(battlePokemon.currentHP) / \(battlePokemon.maxHP)")
                        DetailRow(label: "Attack", value: battlePokemon.attackName)
                        DetailRow(label: "Damage", value: "\(battlePokemon.damage)")

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Attack Description")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(battlePokemon.attackDescription)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Card Info")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(battlePokemon.pokemonDescription)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
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
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
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
