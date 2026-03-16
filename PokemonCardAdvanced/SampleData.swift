import Foundation

// Starter Pokemon roster for the advanced battle project.
// Nova stays in the game, but the stats are balanced for a simple classroom battle.
let samplePokemon: [Pokemon] = [
    Pokemon(
        imageName: "Pikachu",
        name: "Pikachu",
        maxHP: 120,
        attackName: "Thunder Shock",
        attackEnergyCost: 1,
        retreatCost: 1,
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
        attackEnergyCost: 1,
        retreatCost: 0,
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
        attackEnergyCost: 1,
        retreatCost: 2,
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
        attackEnergyCost: 1,
        retreatCost: 1,
        damage: 26,
        attackDescription: "A burst of flame that hits hard.",
        type: "Fire",
        pokemonDescription: "A fiery attacker that trades power for a little less health."
    ),
    Pokemon(
        imageName: "Raichu",
        name: "Raichu",
        maxHP: 145,
        attackName: "Thunderbolt",
        attackEnergyCost: 2,
        retreatCost: 2,
        damage: 28,
        attackDescription: "A heavy electric attack that can finish battles quickly.",
        type: "Electric",
        pokemonDescription: "A stronger electric Pokemon with solid overall stats."
    ),
    Pokemon(
        imageName: "Pidgey",
        name: "Pidgey",
        maxHP: 100,
        attackName: "Gust",
        attackEnergyCost: 1,
        retreatCost: 1,
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
        attackEnergyCost: 2,
        retreatCost: 2,
        damage: 30,
        attackDescription: "Nova charges in with a wild power strike.",
        type: "Custom",
        pokemonDescription: "Your custom fighter returns as the final opponent in the advanced battle."
    )
]

let playerStarter = samplePokemon.first { $0.name == "Pikachu" }!
let opponentStarter = samplePokemon.first { $0.name == "Nova" }!

func pokemon(named name: String) -> Pokemon {
    samplePokemon.first { $0.name == name }!
}

let samplePlayerDeck: [Pokemon] = [
    pokemon(named: "Pikachu"),
    pokemon(named: "Bulbasaur"),
    pokemon(named: "Charmander"),
    pokemon(named: "Abra"),
    pokemon(named: "Pidgey"),
    pokemon(named: "Raichu")
]

let sampleOpponentDeck: [Pokemon] = [
    pokemon(named: "Nova"),
    pokemon(named: "Raichu"),
    pokemon(named: "Pidgey"),
    pokemon(named: "Charmander"),
    pokemon(named: "Bulbasaur"),
    pokemon(named: "Abra")
]
