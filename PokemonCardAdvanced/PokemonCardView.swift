import SwiftUI

struct PokemonCardView: View {
    let title: String
    let battlePokemon: BattlePokemon?

    // Card color matches the Pokemon type to keep the original theme.
    var backgroundColor: Color {
        guard let battlePokemon else {
            return .white
        }

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
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()

                if let battlePokemon {
                    Text("HP \(battlePokemon.currentHP)/\(battlePokemon.maxHP)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }

            if let battlePokemon {
                Text(battlePokemon.name)
                    .font(.title2)
                    .fontWeight(.bold)

                ProgressView(value: Double(battlePokemon.currentHP), total: Double(battlePokemon.maxHP))
                    .tint(.red)

                HStack(spacing: 16) {
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
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Empty Slot")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Choose a Pokemon from your hand during setup or wait for a bench promotion.")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            }
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

struct BoardStatusView: View {
    let title: String
    let deckCount: Int
    let handCount: Int
    let discardCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)

            Spacer()

            BoardCountBadge(label: "Deck", value: deckCount)
            BoardCountBadge(label: "Hand", value: handCount)
            BoardCountBadge(label: "Discard", value: discardCount)
        }
    }
}

struct BoardCountBadge: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct BenchRowView: View {
    let cards: [BattlePokemon]
    let maxSlots: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bench")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(cards) { card in
                    CompactPokemonCardView(battlePokemon: card)
                }

                ForEach(0..<max(0, maxSlots - cards.count), id: \.self) { _ in
                    EmptyCompactSlotView()
                }
            }
        }
    }
}

struct CompactPokemonCardView: View {
    let battlePokemon: BattlePokemon

    var body: some View {
        VStack(spacing: 8) {
            Image(battlePokemon.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 62, height: 62)

            Text(battlePokemon.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text("\(battlePokemon.currentHP) HP")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 94, height: 120)
        .padding(8)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
    }
}

struct EmptyCompactSlotView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Open Bench")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: 94, height: 120)
        .padding(8)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                .foregroundStyle(Color.black.opacity(0.15))
        )
    }
}

struct HandCardView: View {
    let battlePokemon: BattlePokemon
    let showMakeActive: Bool
    let showBench: Bool
    let onMakeActive: () -> Void
    let onBench: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(battlePokemon.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 84)
                .frame(maxWidth: .infinity)

            Text(battlePokemon.name)
                .font(.headline)

            Text("\(battlePokemon.maxHP) HP")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(battlePokemon.attackName)
                .font(.caption)
                .lineLimit(1)

            Spacer(minLength: 0)

            if showMakeActive {
                Button("Make Active", action: onMakeActive)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }

            if showBench {
                Button("Move to Bench", action: onBench)
                    .buttonStyle(.bordered)
            }
        }
        .frame(width: 180, minHeight: 240, alignment: .topLeading)
        .padding()
        .background(Color.white.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}
