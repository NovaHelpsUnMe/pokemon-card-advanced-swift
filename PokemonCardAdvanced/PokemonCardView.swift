import SwiftUI

struct PokemonCardView: View {
    let title: String
    let battlePokemon: BattlePokemon?
    var emphasis: CardEmphasis = .regular

    enum CardEmphasis {
        case regular
        case compact
    }

    private var cardHeight: CGFloat {
        emphasis == .regular ? 172 : 144
    }

    private var imageSize: CGFloat {
        emphasis == .regular ? 86 : 68
    }

    private var backgroundColor: Color {
        guard let battlePokemon else {
            return Color.white.opacity(0.72)
        }

        switch battlePokemon.type {
        case "Fire":
            return Color.orange.opacity(0.72)
        case "Electric":
            return Color.yellow.opacity(0.72)
        case "Grass/Poison":
            return Color.green.opacity(0.72)
        case "Psychic":
            return Color.purple.opacity(0.6)
        case "Normal/Flying":
            return Color.gray.opacity(0.58)
        case "Custom":
            return Color.blue.opacity(0.64)
        default:
            return Color.yellow.opacity(0.7)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.14))
                    .clipShape(Capsule())

                Spacer()

                if let battlePokemon {
                    Text("HP \(battlePokemon.currentHP)/\(battlePokemon.maxHP)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.7))
                        .clipShape(Capsule())
                }
            }

            if let battlePokemon {
                HStack(spacing: 12) {
                    Image(battlePokemon.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                        .padding(8)
                        .background(Color.white.opacity(0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(battlePokemon.name)
                            .font(emphasis == .regular ? .title3 : .headline)
                            .fontWeight(.bold)
                            .lineLimit(1)

                        Text(battlePokemon.type)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        ProgressView(value: Double(battlePokemon.currentHP), total: Double(battlePokemon.maxHP))
                            .tint(.red)

                        Text(battlePokemon.attackName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)

                        Text("\(battlePokemon.damage) damage")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Empty Active Slot")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("Open your hand and choose a Pokemon to lead the battle.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: cardHeight, alignment: .topLeading)
        .padding(14)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.black.opacity(0.15), lineWidth: emphasis == .regular ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}
