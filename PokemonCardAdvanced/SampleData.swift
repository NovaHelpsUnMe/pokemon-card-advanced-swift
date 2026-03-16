import Foundation

// Starter roster for the advanced battle project.
// Nova stays in the game, while Raichu now works as the demo evolution payoff.
let samplePokemon: [Pokemon] = [
    Pokemon(
        imageName: "Pikachu",
        name: "Pikachu",
        maxHP: 120,
        attackName: "Thunder Shock",
        damage: 24,
        attackDescription: "A quick electric blast that keeps the battle moving.",
        type: "Electric",
        pokemonDescription: "A fast electric Pokemon that works well as the player's starter."
    ),
    Pokemon(
        imageName: "Abra",
        name: "Abra",
        maxHP: 90,
        attackName: "Teleport Tap",
        damage: 18,
        attackDescription: "Abra blinks in and surprises the other side.",
        type: "Psychic",
        pokemonDescription: "A psychic Pokemon that prefers quick and tricky moves."
    ),
    Pokemon(
        imageName: "Bulbasaur",
        name: "Bulbasaur",
        maxHP: 130,
        attackName: "Vine Whip",
        damage: 22,
        attackDescription: "Bulbasaur lashes out with a strong vine attack.",
        type: "Grass/Poison",
        pokemonDescription: "A steady grass Pokemon with strong defense."
    ),
    Pokemon(
        imageName: "Charmander",
        name: "Charmander",
        maxHP: 110,
        attackName: "Ember",
        damage: 26,
        attackDescription: "A burst of flame that hits hard.",
        type: "Fire",
        pokemonDescription: "A fiery attacker that trades power for a little less health."
    ),
    Pokemon(
        imageName: "Raichu",
        name: "Raichu",
        maxHP: 155,
        attackName: "Thunderbolt",
        damage: 34,
        attackDescription: "A heavy electric attack that rewards evolving Pikachu.",
        type: "Electric",
        pokemonDescription: "A stronger electric Pokemon that takes over once Pikachu is ready to evolve.",
        stage: .stage1,
        evolvesFrom: "Pikachu"
    ),
    Pokemon(
        imageName: "Pidgey",
        name: "Pidgey",
        maxHP: 100,
        attackName: "Gust",
        damage: 20,
        attackDescription: "A quick flap attack that keeps pressure on the other side.",
        type: "Normal/Flying",
        pokemonDescription: "A light flying Pokemon that is useful for the bench or a fast opening."
    ),
    Pokemon(
        imageName: "Nova",
        name: "Nova",
        maxHP: 170,
        attackName: "Box BottyMan",
        damage: 30,
        attackDescription: "Nova charges in with a wild power strike.",
        type: "Custom",
        pokemonDescription: "Your custom fighter returns as the final opponent in the advanced battle."
    )
]

let sampleTrainerCards: [TrainerCard] = [
    TrainerCard(
        name: "Professor's Notes",
        systemImageName: "book.closed.fill",
        effect: .draw(cards: 2),
        effectDescription: "Draw 2 cards.",
        trainerDescription: "A lightweight draw card that helps the demo hand stay active without adding complex rules."
    ),
    TrainerCard(
        name: "Potion",
        systemImageName: "cross.case.fill",
        effect: .heal(amount: 30),
        effectDescription: "Heal 30 damage from your Active Pokemon.",
        trainerDescription: "A simple recovery effect that gives the player one clean defensive option."
    ),
    TrainerCard(
        name: "Energy Drink",
        systemImageName: "bolt.fill",
        effect: .attachEnergy(amount: 1),
        effectDescription: "Attach 1 extra energy to your Active Pokemon.",
        trainerDescription: "Adds one more attached energy so evolution state changes are visible in the demo."
    )
]

let playerStarter = samplePokemon.first { $0.name == "Pikachu" }!
let opponentStarter = samplePokemon.first { $0.name == "Nova" }!

func pokemon(named name: String) -> Pokemon {
    samplePokemon.first { $0.name == name }!
}

func trainer(named name: String) -> TrainerCard {
    sampleTrainerCards.first { $0.name == name }!
}

let samplePlayerDeck: [CardDefinition] = [
    .pokemon(pokemon(named: "Pikachu")),
    .pokemon(pokemon(named: "Bulbasaur")),
    .trainer(trainer(named: "Professor's Notes")),
    .pokemon(pokemon(named: "Raichu")),
    .trainer(trainer(named: "Potion")),
    .pokemon(pokemon(named: "Charmander")),
    .trainer(trainer(named: "Energy Drink")),
    .pokemon(pokemon(named: "Abra")),
    .pokemon(pokemon(named: "Pidgey"))
]

let sampleOpponentDeck: [CardDefinition] = [
    .pokemon(pokemon(named: "Nova")),
    .pokemon(pokemon(named: "Charmander")),
    .pokemon(pokemon(named: "Bulbasaur")),
    .pokemon(pokemon(named: "Abra")),
    .pokemon(pokemon(named: "Pidgey")),
    .pokemon(pokemon(named: "Pikachu"))
]
