import SwiftUI

enum PokemonCardDisplayStyle {
    case standard
    case board
    case benchCompact
}

struct PokemonCardView: View {
    let title: String
    let battlePokemon: BattlePokemon?
    var displayStyle: PokemonCardDisplayStyle = .standard

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

    private var imageSize: CGFloat {
        switch displayStyle {
        case .standard:
            return 120
        case .board:
            return 72
        case .benchCompact:
            return 34
        }
    }

    private var titleFont: Font {
        switch displayStyle {
        case .standard, .board:
            return .caption
        case .benchCompact:
            return .system(size: 8, weight: .semibold)
        }
    }

    private var hpFont: Font {
        switch displayStyle {
        case .standard:
            return .subheadline
        case .board:
            return .caption
        case .benchCompact:
            return .system(size: 8, weight: .bold)
        }
    }

    private var nameFont: Font {
        switch displayStyle {
        case .standard:
            return .title2
        case .board:
            return .headline
        case .benchCompact:
            return .system(size: 10, weight: .bold)
        }
    }

    private var attackTitleFont: Font {
        switch displayStyle {
        case .standard:
            return .headline
        case .board:
            return .caption
        case .benchCompact:
            return .system(size: 8, weight: .medium)
        }
    }

    private var attackFont: Font {
        switch displayStyle {
        case .standard:
            return .subheadline
        case .board:
            return .caption
        case .benchCompact:
            return .system(size: 8, weight: .semibold)
        }
    }

    private var bodyFont: Font {
        switch displayStyle {
        case .standard:
            return .caption
        case .board:
            return .caption2
        case .benchCompact:
            return .system(size: 8)
        }
    }

    private var showsFlavorText: Bool {
        displayStyle == .standard
    }

    private var cardSpacing: CGFloat {
        switch displayStyle {
        case .standard:
            return 12
        case .board:
            return 8
        case .benchCompact:
            return 4
        }
    }

    private var cardPadding: CGFloat {
        switch displayStyle {
        case .standard:
            return 16
        case .board:
            return 12
        case .benchCompact:
            return 6
        }
    }

    private var artworkPadding: CGFloat {
        switch displayStyle {
        case .standard:
            return 8
        case .board:
            return 6
        case .benchCompact:
            return 3
        }
    }

    private var artworkCornerRadius: CGFloat {
        switch displayStyle {
        case .standard:
            return 16
        case .board:
            return 14
        case .benchCompact:
            return 10
        }
    }

    private var cardCornerRadius: CGFloat {
        displayStyle == .benchCompact ? 16 : 22
    }

    private var cardBorderWidth: CGFloat {
        displayStyle == .benchCompact ? 1.5 : 2
    }

    private var cardShadowRadius: CGFloat {
        displayStyle == .benchCompact ? 4 : 8
    }

    var body: some View {
        Group {
            switch displayStyle {
            case .standard, .board:
                standardCardContent
            case .benchCompact:
                compactBenchCardContent
            }
        }
        .padding(cardPadding)
        .background(backgroundColor.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(Color.black.opacity(0.2), lineWidth: cardBorderWidth)
        )
        .shadow(color: .black.opacity(0.1), radius: cardShadowRadius, x: 0, y: 4)
    }

    private var standardCardContent: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            HStack {
                titleBadge

                Spacer()

                if let battlePokemon {
                    Text("HP \(battlePokemon.currentHP)/\(battlePokemon.maxHP)")
                        .font(hpFont)
                        .fontWeight(.bold)
                }
            }

            if let battlePokemon {
                Text(battlePokemon.name)
                    .font(nameFont)
                    .fontWeight(.bold)
                    .lineLimit(displayStyle == .board ? 1 : 2)

                Text("\(battlePokemon.stage.rawValue) • Energy \(battlePokemon.attachedEnergy)")
                    .font(bodyFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ProgressView(value: Double(battlePokemon.currentHP), total: Double(battlePokemon.maxHP))
                    .tint(.red)

                HStack(alignment: .top, spacing: displayStyle == .board ? 10 : 16) {
                    artworkView(for: battlePokemon)

                    VStack(alignment: .leading, spacing: displayStyle == .board ? 5 : 8) {
                        Text("Attack")
                            .font(attackTitleFont)
                            .foregroundStyle(.secondary)

                        Text(battlePokemon.attackName)
                            .font(attackFont)
                            .fontWeight(.semibold)
                            .lineLimit(displayStyle == .board ? 1 : 2)

                        Text("Damage: \(battlePokemon.damage)")
                            .font(attackFont)

                        Text(battlePokemon.attackDescription)
                            .font(bodyFont)
                            .lineLimit(displayStyle == .board ? 2 : nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if showsFlavorText {
                    Divider()

                    Text(battlePokemon.pokemonDescription)
                        .font(.caption)
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                emptyCardContent
            }
        }
    }

    private var compactBenchCardContent: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            HStack(spacing: 4) {
                titleBadge

                Spacer(minLength: 2)

                if let battlePokemon {
                    Text("\(battlePokemon.currentHP)/\(battlePokemon.maxHP)")
                        .font(hpFont)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            if let battlePokemon {
                Text(battlePokemon.name)
                    .font(nameFont)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("E\(battlePokemon.attachedEnergy)")
                    .font(bodyFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                ProgressView(value: Double(battlePokemon.currentHP), total: Double(battlePokemon.maxHP))
                    .tint(.red)
                    .scaleEffect(x: 1, y: 0.75, anchor: .center)

                artworkView(for: battlePokemon)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 1) {
                    Text(battlePokemon.attackName)
                        .font(attackFont)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("\(battlePokemon.damage) dmg")
                        .font(bodyFont)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                emptyCardContent
            }
        }
    }

    private var titleBadge: some View {
        Text(title)
            .font(titleFont)
            .fontWeight(.semibold)
            .padding(.horizontal, displayStyle == .benchCompact ? 6 : 10)
            .padding(.vertical, displayStyle == .benchCompact ? 2 : 4)
            .background(Color.black.opacity(0.12))
            .clipShape(Capsule())
    }

    private var emptyCardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Empty Slot")
                .font(displayStyle == .standard ? .title3 : .headline)
                .fontWeight(.bold)

            Text("Choose a Pokemon from your hand during setup or wait for a bench promotion.")
                .font(displayStyle == .standard ? .subheadline : .caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: displayStyle == .benchCompact ? 0 : 120, alignment: .leading)
    }

    private func artworkView(for battlePokemon: BattlePokemon) -> some View {
        Image(battlePokemon.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
            .padding(artworkPadding)
            .background(Color.white.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: artworkCornerRadius))
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 120)        .padding()
        .background(Color.white.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}
