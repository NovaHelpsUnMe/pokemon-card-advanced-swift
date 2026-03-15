import SwiftUI

struct PokemonCardView: View {
    let title: String
    let battlePokemon: BattlePokemon

    // Card color matches the Pokemon type to keep the original theme.
    var backgroundColor: Color {
        switch battlePokemon.type {
        case "Fire":
            return .orange
        case "Electric":
            return .yellow
        case "Grass/Poison":
            return .green
        case "Psychic":
            return .purple
        case "Normal/Flying":
            return .gray
        case "Custom":
            return .blue
        default:
            return .yellow
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header with name and current HP.
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                Text("HP \(battlePokemon.currentHP)/\(battlePokemon.maxHP)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            Text(battlePokemon.name)
                .font(.title2)
                .fontWeight(.bold)

            // HP bar updates live as attacks happen.
            ProgressView(value: Double(battlePokemon.currentHP), total: Double(battlePokemon.maxHP))
                .tint(.red)

            HStack(spacing: 16) {
                // Pokemon image from the copied asset catalog.
                Image(battlePokemon.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(8)
                    .background(Color.white.opacity(0.65))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Attack")
                        .font(.headline)

                    Text(battlePokemon.attackName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("Damage: \(battlePokemon.damage)")
                        .font(.subheadline)

                    Text(battlePokemon.attackDescription)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider()

            Text(battlePokemon.pokemonDescription)
                .font(.caption)
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(backgroundColor.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
