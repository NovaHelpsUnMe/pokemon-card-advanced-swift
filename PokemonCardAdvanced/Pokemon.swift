import Foundation

// Base Pokemon data used to build battle characters.
struct Pokemon: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
    let maxHP: Int
    let attackName: String
    let damage: Int
    let attackDescription: String
    let type: String
    let pokemonDescription: String
}

// BattlePokemon stores changing values like current HP during the game.
struct BattlePokemon {
    let pokemon: Pokemon
    var currentHP: Int

    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        self.currentHP = pokemon.maxHP
    }

    var imageName: String { pokemon.imageName }
    var name: String { pokemon.name }
    var maxHP: Int { pokemon.maxHP }
    var attackName: String { pokemon.attackName }
    var damage: Int { pokemon.damage }
    var attackDescription: String { pokemon.attackDescription }
    var type: String { pokemon.type }
    var pokemonDescription: String { pokemon.pokemonDescription }
}
