import Foundation

// Base Pokemon data used to build battle characters.
struct Pokemon: Identifiable, Hashable {
    let id: String
    let imageName: String
    let name: String
    let maxHP: Int
    let attackName: String
    let attackEnergyCost: Int
    let retreatCost: Int
    let damage: Int
    let attackDescription: String
    let type: String
    let pokemonDescription: String

    init(
        imageName: String,
        name: String,
        maxHP: Int,
        attackName: String,
        attackEnergyCost: Int,
        retreatCost: Int,
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
        self.attackEnergyCost = attackEnergyCost
        self.retreatCost = retreatCost
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
    var attachedEnergy: Int

    init(id: UUID = UUID(), pokemon: Pokemon, attachedEnergy: Int = 0) {
        self.id = id
        self.pokemon = pokemon
        self.currentHP = pokemon.maxHP
        self.attachedEnergy = attachedEnergy
    }

    var imageName: String { pokemon.imageName }
    var name: String { pokemon.name }
    var maxHP: Int { pokemon.maxHP }
    var attackName: String { pokemon.attackName }
    var attackEnergyCost: Int { pokemon.attackEnergyCost }
    var retreatCost: Int { pokemon.retreatCost }
    var damage: Int { pokemon.damage }
    var attackDescription: String { pokemon.attackDescription }
    var type: String { pokemon.type }
    var pokemonDescription: String { pokemon.pokemonDescription }
    var hasEnoughEnergyForAttack: Bool { attachedEnergy >= attackEnergyCost }
    var hasEnoughEnergyToRetreat: Bool { attachedEnergy >= retreatCost }

    mutating func attachEnergy(_ amount: Int = 1) {
        guard amount > 0 else { return }
        attachedEnergy += amount
    }

    @discardableResult
    mutating func spendEnergy(_ amount: Int) -> Bool {
        guard amount >= 0, attachedEnergy >= amount else {
            return false
        }

        attachedEnergy -= amount
        return true
    }
}
