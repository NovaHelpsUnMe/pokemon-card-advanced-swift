import SwiftUI

struct CardDetailSheetView: View {
    let battlePokemon: BattlePokemon

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                Image(battlePokemon.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .padding(8)
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 6) {
                    Text(battlePokemon.name)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(battlePokemon.type)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("HP \(battlePokemon.currentHP)/\(battlePokemon.maxHP)")
                        .font(.headline)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Attack")
                    .font(.headline)

                Text("\(battlePokemon.attackName) • \(battlePokemon.damage) damage")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(battlePokemon.attackDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Card Flavor")
                    .font(.headline)

                Text(battlePokemon.pokemonDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.97, green: 0.93, blue: 0.84))
    }
}
