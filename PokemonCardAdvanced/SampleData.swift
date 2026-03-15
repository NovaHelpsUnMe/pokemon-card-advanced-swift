import Foundation

// Starter Pokemon roster for the advanced battle project.
// Nova stays in the game, but the stats are balanced for a simple classroom battle.
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
        maxHP: 145,
        attackName: "Thunderbolt",
        damage: 28,
        attackDescription: "A heavy electric attack that can finish battles quickly.",
        type: "Electric",
        pokemonDescription: "A stronger electric Pokemon with solid overall stats."
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

let playerStarter = samplePokemon.first { $0.name == "Pikachu" }!
let opponentStarter = samplePokemon.first { $0.name == "Nova" }!
