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
    var deck: [BattlePokemon]
    var hand: [BattlePokemon] = []
    var active: BattlePokemon?
    var bench: [BattlePokemon] = []
    var discard: [BattlePokemon] = []
    let maxBenchSize: Int = 3

    var deckCount: Int { deck.count }
    var handCount: Int { hand.count }
    var discardCount: Int { discard.count }

    mutating func drawCards(_ count: Int) -> [BattlePokemon] {
        guard count > 0, !deck.isEmpty else { return [] }

        let drawCount = min(count, deck.count)
        let drawn = Array(deck.prefix(drawCount))
        deck.removeFirst(drawCount)
        hand.append(contentsOf: drawn)
        return drawn
    }

    mutating func moveHandCardToActive(cardID: UUID) -> BattlePokemon? {
        guard active == nil, let index = hand.firstIndex(where: { $0.id == cardID }) else { return nil }
        let card = hand.remove(at: index)
        active = card
        return card
    }

    mutating func moveHandCardToBench(cardID: UUID) -> BattlePokemon? {
        guard bench.count < maxBenchSize, let index = hand.firstIndex(where: { $0.id == cardID }) else { return nil }
        let card = hand.remove(at: index)
        bench.append(card)
        return card
    }

    mutating func replaceActive(_ card: BattlePokemon?) {
        active = card
    }

    mutating func promoteFirstBenchToActive() -> BattlePokemon? {
        guard !bench.isEmpty else { return nil }
        let promoted = bench.removeFirst()
        active = promoted
        return promoted
    }

    mutating func discardActive() -> BattlePokemon? {
        guard let card = active else { return nil }
        discard.append(card)
        active = nil
        return card
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

    private let playerDeckSeed: [Pokemon]
    private let opponentDeckSeed: [Pokemon]
    private let placeholderPrizeCount = 6

    init(playerDeck: [Pokemon]? = nil, opponentDeck: [Pokemon]? = nil) {
        let resolvedPlayerDeck = playerDeck ?? samplePlayerDeck
        let resolvedOpponentDeck = opponentDeck ?? sampleOpponentDeck
        playerDeckSeed = resolvedPlayerDeck
        opponentDeckSeed = resolvedOpponentDeck
        playerBoard = PlayerBoard(title: "Player", deck: resolvedPlayerDeck.map { BattlePokemon(pokemon: $0) })
        opponentBoard = PlayerBoard(title: "Opponent", deck: resolvedOpponentDeck.map { BattlePokemon(pokemon: $0) })
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
                return "Choose an active Pokemon from your opening hand."
            }

            return "Add bench Pokemon or start the battle."
        case .battle:
            if isGameOver {
                return "The battle is over."
            }

            return isPlayerTurn ? "Play a card to your bench if needed." : "Wait for the opponent's turn to finish."
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

    var canPlayerAddBenchCard: Bool {
        playerBoard.bench.count < playerBoard.maxBenchSize
    }

    func canAssignPlayerActive(_ card: BattlePokemon) -> Bool {
        gamePhase == .setup && playerBoard.active == nil && playerBoard.hand.contains(card)
    }

    func canBenchPlayerCard(_ card: BattlePokemon) -> Bool {
        !isGameOver &&
        playerBoard.bench.count < playerBoard.maxBenchSize &&
        playerBoard.hand.contains(card) &&
        (gamePhase == .setup || isPlayerTurn)
    }

    func handCardActionSummary(for card: BattlePokemon) -> String {
        if canAssignPlayerActive(card) {
            return "Make Active"
        }

        if canBenchPlayerCard(card) {
            return "Move to Bench"
        }

        if isGameOver {
            return "Unavailable"
        }

        switch gamePhase {
        case .setup:
            if playerBoard.active != nil && playerBoard.bench.count >= playerBoard.maxBenchSize {
                return "Bench Full"
            }

            return "Waiting"
        case .battle:
            return isPlayerTurn ? "No Action" : "Opponent Turn"
        }
    }

    func placePlayerActive(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToActive(cardID: cardID) else { return }
        battleMessage = "\(card.name) is now your active Pokemon. Add bench Pokemon or start the battle."
    }

    func placePlayerBench(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToBench(cardID: cardID) else { return }

        if gamePhase == .setup {
            battleMessage = "\(card.name) moved to your bench. You can add more bench Pokemon or start the battle."
        } else {
            battleMessage = "\(card.name) joined your bench from your hand."
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
        playerBoard = PlayerBoard(title: "Player", deck: playerDeckSeed.map { BattlePokemon(pokemon: $0) })
        opponentBoard = PlayerBoard(title: "Opponent", deck: opponentDeckSeed.map { BattlePokemon(pokemon: $0) })
        gamePhase = .setup
        currentTurn = .player
        playerBoard.drawCards(5)
        opponentBoard.drawCards(5)
        autoSetupOpponentBoard()
        battleMessage = "Choose an active Pokemon from your opening hand."
        resultTitle = nil
        resultMessage = nil
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
        if let activeCard = opponentBoard.hand.first {
            _ = opponentBoard.moveHandCardToActive(cardID: activeCard.id)
        }

        while opponentBoard.bench.count < 2, let nextCard = opponentBoard.hand.first {
            _ = opponentBoard.moveHandCardToBench(cardID: nextCard.id)
        }
    }

    private func refillOpponentBenchIfPossible() {
        while opponentBoard.bench.count < 2, let nextCard = opponentBoard.hand.first {
            _ = opponentBoard.moveHandCardToBench(cardID: nextCard.id)
        }
    }

    private func startOpponentTurn(after message: String) {
        currentTurn = .opponent
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
