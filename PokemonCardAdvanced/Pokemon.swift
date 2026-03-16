import Foundation

// Base Pokemon data used to build battle characters.
struct Pokemon: Identifiable, Hashable {
    let id: String
    let imageName: String
    let name: String
    let maxHP: Int
    let attackName: String
    let damage: Int
    let attackDescription: String
    let type: String
    let pokemonDescription: String

    init(
        imageName: String,
        name: String,
        maxHP: Int,
        attackName: String,
        damage: Int,
        attackDescription: String,
        type: String,
        pokemonDescription: String
    ) {
        id = name
        self.imageName = imageName
        self.name = name
        self.maxHP = maxHP
        self.attackName = attackName
        self.damage = damage
        self.attackDescription = attackDescription
        self.type = type
        self.pokemonDescription = pokemonDescription
    }
}

// BattlePokemon stores changing values like current HP during the game.
struct BattlePokemon: Identifiable, Equatable {
    let id: UUID
    let pokemon: Pokemon
    var currentHP: Int

    init(id: UUID = UUID(), pokemon: Pokemon) {
        self.id = id
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
