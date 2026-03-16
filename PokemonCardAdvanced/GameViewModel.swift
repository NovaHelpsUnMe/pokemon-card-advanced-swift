import Combine
import Foundation
import SwiftUI

enum BattleTurn {
    case player
    case opponent
}

enum GamePhase {
    case setup
    case battle
}

struct PlayerBoard {
    let title: String
    var deck: [BattleCard]
    var hand: [BattleCard] = []
    var active: BattlePokemon?
    var bench: [BattlePokemon] = []
    var discard: [BattleCard] = []
    let maxBenchSize: Int = 3

    var deckCount: Int { deck.count }
    var handCount: Int { hand.count }
    var discardCount: Int { discard.count }

    mutating func drawCards(_ count: Int) -> [BattleCard] {
        guard count > 0, !deck.isEmpty else { return [] }

        let drawCount = min(count, deck.count)
        let drawn = Array(deck.prefix(drawCount))
        deck.removeFirst(drawCount)
        hand.append(contentsOf: drawn)
        return drawn
    }

    mutating func moveHandCardToActive(cardID: UUID, countsAsPlayedThisTurn: Bool) -> BattlePokemon? {
        guard active == nil,
              let index = hand.firstIndex(where: { $0.id == cardID }),
              let pokemon = hand[index].pokemon,
              pokemon.stage == .basic else {
            return nil
        }

        hand.remove(at: index)
        let battlePokemon = BattlePokemon(
            pokemon: pokemon,
            wasPlayedThisTurn: countsAsPlayedThisTurn
        )
        active = battlePokemon
        return battlePokemon
    }

    mutating func moveHandCardToBench(cardID: UUID, countsAsPlayedThisTurn: Bool) -> BattlePokemon? {
        guard bench.count < maxBenchSize,
              let index = hand.firstIndex(where: { $0.id == cardID }),
              let pokemon = hand[index].pokemon,
              pokemon.stage == .basic else {
            return nil
        }

        hand.remove(at: index)
        let battlePokemon = BattlePokemon(
            pokemon: pokemon,
            wasPlayedThisTurn: countsAsPlayedThisTurn
        )
        bench.append(battlePokemon)
        return battlePokemon
    }

    mutating func removeHandCard(cardID: UUID) -> BattleCard? {
        guard let index = hand.firstIndex(where: { $0.id == cardID }) else { return nil }
        return hand.remove(at: index)
    }

    mutating func replaceActive(_ card: BattlePokemon?) {
        active = card
    }

    mutating func replaceBenchCard(targetID: UUID, with battlePokemon: BattlePokemon) {
        guard let index = bench.firstIndex(where: { $0.id == targetID }) else { return }
        bench[index] = battlePokemon
    }

    mutating func promoteFirstBenchToActive() -> BattlePokemon? {
        guard !bench.isEmpty else { return nil }
        let promoted = bench.removeFirst()
        active = promoted
        return promoted
    }

    mutating func discardActive() -> BattlePokemon? {
        guard let card = active else { return nil }
        discard.append(contentsOf: card.discardCards())
        active = nil
        return card
    }

    mutating func discardUsedTrainer(_ card: BattleCard) {
        discard.append(card)
    }

    mutating func clearPlayedThisTurnFlags() {
        if var active {
            active.wasPlayedThisTurn = false
            self.active = active
        }

        for index in bench.indices {
            bench[index].wasPlayedThisTurn = false
        }
    }
}

// GameViewModel controls the battle rules and published game state.
@MainActor
final class GameViewModel: ObservableObject {
    @Published var playerBoard: PlayerBoard
    @Published var opponentBoard: PlayerBoard
    @Published var gamePhase: GamePhase = .setup
    @Published var currentTurn: BattleTurn = .player
    @Published var battleMessage: String
    @Published var resultTitle: String?
    @Published var resultMessage: String?

    private let playerDeckSeed: [CardDefinition]
    private let opponentDeckSeed: [CardDefinition]
    private let placeholderPrizeCount = 6

    init(playerDeck: [CardDefinition]? = nil, opponentDeck: [CardDefinition]? = nil) {
        let resolvedPlayerDeck = playerDeck ?? samplePlayerDeck
        let resolvedOpponentDeck = opponentDeck ?? sampleOpponentDeck
        playerDeckSeed = resolvedPlayerDeck
        opponentDeckSeed = resolvedOpponentDeck
        playerBoard = PlayerBoard(title: "Player", deck: Self.makeDeck(from: resolvedPlayerDeck))
        opponentBoard = PlayerBoard(title: "Opponent", deck: Self.makeDeck(from: resolvedOpponentDeck))
        battleMessage = "Choose an active Pokemon from your opening hand."
        restartGame()
    }

    var phaseLabel: String {
        switch gamePhase {
        case .setup:
            return "Setup Phase"
        case .battle:
            return isGameOver ? "Game Over" : turnLabel
        }
    }

    var isPlayerTurn: Bool {
        currentTurn == .player && gamePhase == .battle && !isGameOver
    }

    var isGameOver: Bool {
        resultTitle != nil
    }

    var turnLabel: String {
        switch currentTurn {
        case .player:
            return "Player Turn"
        case .opponent:
            return "Opponent Turn"
        }
    }

    var attackButtonTitle: String {
        "\(playerBoard.active?.attackName ?? "Attack")"
    }

    var isAttackButtonEnabled: Bool {
        isPlayerTurn && playerBoard.active != nil
    }

    var isRestartButtonVisible: Bool {
        true
    }

    var isRestartButtonEnabled: Bool {
        true
    }

    var playerHandButtonTitle: String {
        "Hand (\(playerBoard.handCount))"
    }

    var playerHandSheetTitle: String {
        gamePhase == .setup ? "Choose Your Pokemon" : "Your Hand"
    }

    var playerHandSheetSubtitle: String {
        switch gamePhase {
        case .setup:
            if playerBoard.active == nil {
                return "Choose a Basic Pokemon for your active spot."
            }

            return "Add more Basic Pokemon to the bench or start the battle."
        case .battle:
            if isGameOver {
                return "The battle is over."
            }

            return isPlayerTurn
                ? "Play a trainer, evolve a Pokemon, or bench a Basic Pokemon."
                : "Wait for the opponent's turn to finish."
        }
    }

    var playerVisibleDeckCount: Int {
        playerBoard.deckCount
    }

    var playerVisibleDiscardCount: Int {
        playerBoard.discardCount
    }

    var playerPrizesRemaining: Int {
        placeholderPrizeCount
    }

    var opponentVisibleDeckCount: Int {
        opponentBoard.deckCount
    }

    var opponentVisibleDiscardCount: Int {
        opponentBoard.discardCount
    }

    var opponentPrizesRemaining: Int {
        placeholderPrizeCount
    }

    var canStartBattle: Bool {
        gamePhase == .setup && playerBoard.active != nil && opponentBoard.active != nil
    }

    func canAssignPlayerActive(_ card: BattleCard) -> Bool {
        gamePhase == .setup &&
        playerBoard.active == nil &&
        card.isBasicPokemon &&
        playerBoard.hand.contains(where: { $0.id == card.id })
    }

    func canBenchPlayerCard(_ card: BattleCard) -> Bool {
        !isGameOver &&
        playerBoard.bench.count < playerBoard.maxBenchSize &&
        card.isBasicPokemon &&
        playerBoard.hand.contains(where: { $0.id == card.id }) &&
        (gamePhase == .setup || isPlayerTurn)
    }

    func playerActiveEvolutionTarget(for card: BattleCard) -> BattlePokemon? {
        guard isPlayerTurn,
              gamePhase == .battle,
              let evolution = card.pokemon,
              evolution.stage != .basic,
              playerBoard.hand.contains(where: { $0.id == card.id }),
              let active = playerBoard.active,
              active.canEvolve(with: evolution) else {
            return nil
        }

        return active
    }

    func playerBenchEvolutionTargets(for card: BattleCard) -> [BattlePokemon] {
        guard isPlayerTurn,
              gamePhase == .battle,
              let evolution = card.pokemon,
              evolution.stage != .basic,
              playerBoard.hand.contains(where: { $0.id == card.id }) else {
            return []
        }

        return playerBoard.bench.filter { $0.canEvolve(with: evolution) }
    }

    func canPlayTrainer(_ card: BattleCard) -> Bool {
        guard isPlayerTurn,
              gamePhase == .battle,
              !isGameOver,
              playerBoard.hand.contains(where: { $0.id == card.id }),
              let trainer = card.trainer else {
            return false
        }

        switch trainer.effect {
        case .draw:
            return playerBoard.deckCount > 0
        case .heal:
            return (playerBoard.active?.damageTaken ?? 0) > 0
        case .attachEnergy:
            return playerBoard.active != nil
        }
    }

    func trainerButtonTitle(for card: BattleCard) -> String? {
        card.trainer?.effect.actionLabel
    }

    func handCardActionSummary(for card: BattleCard) -> String {
        if canAssignPlayerActive(card) {
            return "Make Active"
        }

        if canBenchPlayerCard(card) {
            return "Move to Bench"
        }

        if let activeTarget = playerActiveEvolutionTarget(for: card) {
            return "Evolve \(activeTarget.name)"
        }

        let benchTargets = playerBenchEvolutionTargets(for: card)
        if !benchTargets.isEmpty {
            return benchTargets.count == 1 ? "Evolve \(benchTargets[0].name)" : "Choose Evolution Target"
        }

        if canPlayTrainer(card), let title = trainerButtonTitle(for: card) {
            return title
        }

        if isGameOver {
            return "Unavailable"
        }

        if let pokemon = card.pokemon, pokemon.stage != .basic {
            switch gamePhase {
            case .setup:
                return "Play after setup"
            case .battle:
                return isPlayerTurn ? "Needs matching Pokemon" : "Opponent Turn"
            }
        }

        if card.trainer != nil {
            switch gamePhase {
            case .setup:
                return "Play during battle"
            case .battle:
                return isPlayerTurn ? "No legal target" : "Opponent Turn"
            }
        }

        switch gamePhase {
        case .setup:
            if playerBoard.active != nil && playerBoard.bench.count >= playerBoard.maxBenchSize {
                return "Bench Full"
            }

            return "Waiting"
        case .battle:
            if !isPlayerTurn {
                return "Opponent Turn"
            }

            return playerBoard.bench.count >= playerBoard.maxBenchSize ? "Bench Full" : "No Action"
        }
    }

    func placePlayerActive(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToActive(
            cardID: cardID,
            countsAsPlayedThisTurn: gamePhase == .battle
        ) else {
            return
        }

        battleMessage = "\(card.name) is now your active Pokemon. Add bench Pokemon or start the battle."
    }

    func placePlayerBench(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToBench(
            cardID: cardID,
            countsAsPlayedThisTurn: gamePhase == .battle
        ) else {
            return
        }

        if gamePhase == .setup {
            battleMessage = "\(card.name) moved to your bench. You can add more bench Pokemon or start the battle."
        } else {
            battleMessage = "\(card.name) joined your bench from your hand."
        }
    }

    func evolvePlayerPokemon(cardID: UUID, targetID: UUID) {
        guard isPlayerTurn,
              gamePhase == .battle,
              let handCard = playerBoard.hand.first(where: { $0.id == cardID }),
              let evolution = handCard.pokemon,
              evolution.stage != .basic else {
            return
        }

        if let active = playerBoard.active,
           active.id == targetID,
           active.canEvolve(with: evolution) {
            _ = playerBoard.removeHandCard(cardID: cardID)
            let evolved = active.evolved(into: evolution)
            playerBoard.replaceActive(evolved)
            battleMessage = "\(active.name) evolved into \(evolved.name). It kept \(evolved.damageTaken) damage and \(evolved.attachedEnergy) attached energy."
            return
        }

        guard let benchTarget = playerBoard.bench.first(where: { $0.id == targetID }),
              benchTarget.canEvolve(with: evolution) else {
            return
        }

        _ = playerBoard.removeHandCard(cardID: cardID)
        let evolved = benchTarget.evolved(into: evolution)
        playerBoard.replaceBenchCard(targetID: targetID, with: evolved)
        battleMessage = "\(benchTarget.name) evolved into \(evolved.name). It kept \(evolved.damageTaken) damage and \(evolved.attachedEnergy) attached energy."
    }

    func playTrainer(cardID: UUID) {
        guard let handCard = playerBoard.hand.first(where: { $0.id == cardID }),
              let trainer = handCard.trainer,
              canPlayTrainer(handCard),
              let usedCard = playerBoard.removeHandCard(cardID: cardID) else {
            return
        }

        defer {
            playerBoard.discardUsedTrainer(usedCard)
        }

        switch trainer.effect {
        case .draw(let cards):
            let drawnCards = playerBoard.drawCards(cards)
            if drawnCards.isEmpty {
                battleMessage = "\(trainer.name) had no cards left to draw."
            } else {
                let names = drawnCards.map(\.name).joined(separator: ", ")
                battleMessage = "\(trainer.name) drew \(drawnCards.count) card(s): \(names)."
            }
        case .heal(let amount):
            guard var active = playerBoard.active else { return }
            let healed = active.heal(amount)
            playerBoard.replaceActive(active)
            battleMessage = "\(trainer.name) healed \(active.name) for \(healed) HP."
        case .attachEnergy(let amount):
            guard var active = playerBoard.active else { return }
            active.attachEnergy(amount)
            playerBoard.replaceActive(active)
            battleMessage = "\(trainer.name) added \(amount) energy to \(active.name). It now has \(active.attachedEnergy) attached energy."
        }
    }

    func startBattle() {
        guard canStartBattle else { return }

        gamePhase = .battle
        currentTurn = .player
        battleMessage = "Setup complete. \(playerBoard.active?.name ?? "Your active Pokemon") goes first."
    }

    func playerAttack() {
        guard
            isPlayerTurn,
            let attacker = playerBoard.active,
            var defender = opponentBoard.active
        else {
            return
        }

        defender.currentHP = updatedHP(afterAttacking: attacker, defender: defender)
        opponentBoard.replaceActive(defender)

        if defender.currentHP == 0 {
            resolveKnockout(on: .opponent, attackerName: attacker.name)
            return
        }

        startOpponentTurn(after: "\(attacker.name) used \(attacker.attackName) for \(attacker.damage) damage.")
    }

    func restartGame() {
        playerBoard = PlayerBoard(title: "Player", deck: Self.makeDeck(from: playerDeckSeed))
        opponentBoard = PlayerBoard(title: "Opponent", deck: Self.makeDeck(from: opponentDeckSeed))
        gamePhase = .setup
        currentTurn = .player
        _ = playerBoard.drawCards(5)
        _ = opponentBoard.drawCards(5)
        autoSetupOpponentBoard()
        battleMessage = "Choose an active Pokemon from your opening hand."
        resultTitle = nil
        resultMessage = nil
    }

    private static func makeDeck(from seed: [CardDefinition]) -> [BattleCard] {
        seed.map { BattleCard(card: $0) }
    }

    private func scheduleOpponentTurn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.opponentAttack()
        }
    }

    private func opponentAttack() {
        guard
            !isGameOver,
            gamePhase == .battle,
            let attacker = opponentBoard.active,
            var defender = playerBoard.active
        else {
            return
        }

        defender.currentHP = updatedHP(afterAttacking: attacker, defender: defender)
        playerBoard.replaceActive(defender)

        if defender.currentHP == 0 {
            resolveKnockout(on: .player, attackerName: attacker.name)
            return
        }

        refillOpponentBenchIfPossible()
        startPlayerTurn(after: "\(attacker.name) used \(attacker.attackName) for \(attacker.damage) damage.")
    }

    private func updatedHP(afterAttacking attacker: BattlePokemon, defender: BattlePokemon) -> Int {
        max(defender.currentHP - attacker.damage, 0)
    }

    private func autoSetupOpponentBoard() {
        if let activeCardID = opponentBoard.hand.first(where: \.isBasicPokemon)?.id {
            _ = opponentBoard.moveHandCardToActive(cardID: activeCardID, countsAsPlayedThisTurn: false)
        }

        while opponentBoard.bench.count < 2,
              let nextCardID = opponentBoard.hand.first(where: \.isBasicPokemon)?.id {
            _ = opponentBoard.moveHandCardToBench(cardID: nextCardID, countsAsPlayedThisTurn: false)
        }
    }

    private func refillOpponentBenchIfPossible() {
        while opponentBoard.bench.count < 2,
              let nextCardID = opponentBoard.hand.first(where: \.isBasicPokemon)?.id {
            _ = opponentBoard.moveHandCardToBench(cardID: nextCardID, countsAsPlayedThisTurn: true)
        }
    }

    private func startOpponentTurn(after message: String) {
        currentTurn = .opponent
        opponentBoard.clearPlayedThisTurnFlags()
        let drawnCards = opponentBoard.drawCards(1)
        refillOpponentBenchIfPossible()

        if let drawn = drawnCards.first {
            battleMessage = "\(message) Opponent drew \(drawn.name)."
        } else {
            battleMessage = message
        }

        scheduleOpponentTurn()
    }

    private func startPlayerTurn(after message: String) {
        currentTurn = .player
        playerBoard.clearPlayedThisTurnFlags()
        let drawnCards = playerBoard.drawCards(1)
        if let drawn = drawnCards.first {
            battleMessage = "\(message) You drew \(drawn.name)."
        } else {
            battleMessage = message
        }
    }

    private func resolveKnockout(on defendingSide: BattleTurn, attackerName: String) {
        switch defendingSide {
        case .player:
            let knockedOut = playerBoard.discardActive()

            guard let replacement = playerBoard.promoteFirstBenchToActive() else {
                finishGame(
                    title: "You Lose",
                    message: "\(attackerName) knocked out \(knockedOut?.name ?? "your active Pokemon")."
                )
                return
            }

            battleMessage = "\(attackerName) knocked out \(knockedOut?.name ?? "your active Pokemon"). \(replacement.name) moved up from your bench."
            startPlayerTurn(after: battleMessage)

        case .opponent:
            let knockedOut = opponentBoard.discardActive()

            guard let replacement = opponentBoard.promoteFirstBenchToActive() else {
                finishGame(
                    title: "You Win!",
                    message: "\(attackerName) knocked out \(knockedOut?.name ?? "the opponent's active Pokemon")."
                )
                return
            }

            battleMessage = "\(attackerName) knocked out \(knockedOut?.name ?? "the opponent's active Pokemon"). \(replacement.name) moved up from the opponent bench."
            startOpponentTurn(after: battleMessage)
        }
    }

    private func finishGame(title: String, message: String) {
        resultTitle = title
        resultMessage = message
        gamePhase = .battle
        battleMessage = message
    }
}
