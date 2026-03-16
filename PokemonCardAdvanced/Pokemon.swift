import Foundation

enum PokemonStage: String, Hashable {
    case basic = "Basic"
    case stage1 = "Stage 1"
}

enum TrainerEffect: Hashable {
    case draw(cards: Int)
    case heal(amount: Int)
    case attachEnergy(amount: Int)

    var actionLabel: String {
        switch self {
        case .draw(let cards):
            return "Draw \(cards)"
        case .heal(let amount):
            return "Heal \(amount)"
        case .attachEnergy(let amount):
            return "Add \(amount) Energy"
        }
    }
}

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
    let stage: PokemonStage
    let evolvesFrom: String?

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
        pokemonDescription: String,
        stage: PokemonStage = .basic,
        evolvesFrom: String? = nil
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
        self.stage = stage
        self.evolvesFrom = evolvesFrom
    }
}

struct TrainerCard: Identifiable, Hashable {
    let id: String
    let name: String
    let systemImageName: String
    let effect: TrainerEffect
    let effectDescription: String
    let trainerDescription: String

    init(
        name: String,
        systemImageName: String,
        effect: TrainerEffect,
        effectDescription: String,
        trainerDescription: String
    ) {
        id = name
        self.name = name
        self.systemImageName = systemImageName
        self.effect = effect
        self.effectDescription = effectDescription
        self.trainerDescription = trainerDescription
    }
}

enum CardDefinition: Hashable {
    case pokemon(Pokemon)
    case trainer(TrainerCard)

    var name: String {
        switch self {
        case .pokemon(let pokemon):
            return pokemon.name
        case .trainer(let trainer):
            return trainer.name
        }
    }
}

struct BattleCard: Identifiable, Equatable {
    let id: UUID
    let card: CardDefinition

    init(id: UUID = UUID(), card: CardDefinition) {
        self.id = id
        self.card = card
    }

    var name: String {
        card.name
    }

    var pokemon: Pokemon? {
        guard case .pokemon(let pokemon) = card else { return nil }
        return pokemon
    }

    var trainer: TrainerCard? {
        guard case .trainer(let trainer) = card else { return nil }
        return trainer
    }

    var isBasicPokemon: Bool {
        pokemon?.stage == .basic
    }
}

struct BattlePokemon: Identifiable, Equatable {
    let id: UUID
    private(set) var stack: [Pokemon]
    var currentHP: Int
    var attachedEnergy: Int
    var wasPlayedThisTurn: Bool

    init(
        id: UUID = UUID(),
        pokemon: Pokemon,
        attachedEnergy: Int = 0,
        wasPlayedThisTurn: Bool = false
    ) {
        self.id = id
        stack = [pokemon]
        currentHP = pokemon.maxHP
        self.attachedEnergy = attachedEnergy
        self.wasPlayedThisTurn = wasPlayedThisTurn
    }

    var pokemon: Pokemon { stack.last! }
    var evolutionLine: [Pokemon] { stack }
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
    var stage: PokemonStage { pokemon.stage }
    var evolvesFrom: String? { pokemon.evolvesFrom }
    var damageTaken: Int { max(maxHP - currentHP, 0) }
    var hasEnoughEnergyForAttack: Bool { attachedEnergy >= attackEnergyCost }
    var hasEnoughEnergyToRetreat: Bool { attachedEnergy >= retreatCost }

    func canEvolve(with evolution: Pokemon) -> Bool {
        evolution.stage != .basic &&
        evolution.evolvesFrom == name &&
        !wasPlayedThisTurn
    }

    func evolved(into evolution: Pokemon) -> BattlePokemon {
        let preservedDamage = damageTaken
        var next = self
        next.stack.append(evolution)
        next.currentHP = max(evolution.maxHP - preservedDamage, 0)
        next.wasPlayedThisTurn = true
        return next
    }

    mutating func heal(_ amount: Int) -> Int {
        let healedAmount = min(amount, maxHP - currentHP)
        currentHP += healedAmount
        return healedAmount
    }

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

    func discardCards() -> [BattleCard] {
        evolutionLine.map { BattleCard(card: .pokemon($0)) }
    }
}
