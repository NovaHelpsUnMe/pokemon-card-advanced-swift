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
    var prizesRemaining: Int = 3
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

    init(playerDeck: [Pokemon]? = nil, opponentDeck: [Pokemon]? = nil) {
        let resolvedPlayerDeck = playerDeck ?? samplePlayerDeck
        let resolvedOpponentDeck = opponentDeck ?? sampleOpponentDeck
        playerDeckSeed = resolvedPlayerDeck
        opponentDeckSeed = resolvedOpponentDeck
        playerBoard = PlayerBoard(title: "Player", deck: resolvedPlayerDeck.map { BattlePokemon(pokemon: $0) })
        opponentBoard = PlayerBoard(title: "Opponent", deck: resolvedOpponentDeck.map { BattlePokemon(pokemon: $0) })
        battleMessage = "Choose an active Pokemon from your hand."
        restartGame()
    }

    var phaseLabel: String {
        switch gamePhase {
        case .setup:
            return "Setup"
        case .battle:
            return isGameOver ? "Game Over" : turnLabel
        }
    }

    var turnLabel: String {
        switch currentTurn {
        case .player:
            return "Player Turn"
        case .opponent:
            return "Opponent Turn"
        }
    }

    var isPlayerTurn: Bool {
        currentTurn == .player && gamePhase == .battle && !isGameOver
    }

    var isGameOver: Bool {
        resultTitle != nil
    }

    var attackButtonTitle: String {
        playerBoard.active?.attackName ?? "Attack"
    }

    var isAttackEnabled: Bool {
        isPlayerTurn && playerBoard.active != nil && opponentBoard.active != nil
    }

    var canStartBattle: Bool {
        gamePhase == .setup && playerBoard.active != nil && opponentBoard.active != nil
    }

    var canRestartFromBar: Bool {
        isGameOver
    }

    var handButtonTitle: String {
        "Hand \(playerBoard.handCount)"
    }

    var handSheetTitle: String {
        gamePhase == .setup ? "Choose Your Setup" : "Player Hand"
    }

    var handSheetSubtitle: String {
        if playerBoard.hand.isEmpty {
            return "No cards in hand."
        }

        switch gamePhase {
        case .setup:
            return "Pick one Active Pokemon, then add Bench cards."
        case .battle:
            return isPlayerTurn ? "Play a Pokemon to your bench or inspect details." : "You can inspect your cards while the opponent acts."
        }
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

    func cardActionSummary(for card: BattlePokemon) -> String {
        if canAssignPlayerActive(card) {
            return "Can become your Active Pokemon."
        }

        if canBenchPlayerCard(card) {
            return "Can be played to your bench."
        }

        if gamePhase == .setup {
            return "Finish your Active Pokemon first."
        }

        return "Inspect only right now."
    }

    func placePlayerActive(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToActive(cardID: cardID) else { return }
        battleMessage = "\(card.name) is now your Active Pokemon. Add Bench Pokemon or start the battle."
    }

    func placePlayerBench(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToBench(cardID: cardID) else { return }

        if gamePhase == .setup {
            battleMessage = "\(card.name) moved to your bench. You can add more Bench Pokemon or start the battle."
        } else {
            battleMessage = "\(card.name) joined your bench from your hand."
        }
    }

    func startBattle() {
        guard canStartBattle else { return }

        gamePhase = .battle
        currentTurn = .player
        battleMessage = "Setup complete. \(playerBoard.active?.name ?? "Your Active Pokemon") attacks first."
    }

    func playerAttack() {
        guard
            isAttackEnabled,
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
        resultTitle = nil
        resultMessage = nil

        _ = playerBoard.drawCards(5)
        _ = opponentBoard.drawCards(5)
        autoSetupOpponentBoard()
        battleMessage = "Choose an Active Pokemon from your hand."
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
            playerBoard.prizesRemaining = max(playerBoard.prizesRemaining - 1, 0)

            guard let replacement = playerBoard.promoteFirstBenchToActive() else {
                finishGame(
                    title: "You Lose",
                    message: "\(attackerName) knocked out \(knockedOut?.name ?? "your Active Pokemon")."
                )
                return
            }

            battleMessage = "\(attackerName) knocked out \(knockedOut?.name ?? "your Active Pokemon"). \(replacement.name) moved up from your bench."
            startPlayerTurn(after: battleMessage)

        case .opponent:
            let knockedOut = opponentBoard.discardActive()
            opponentBoard.prizesRemaining = max(opponentBoard.prizesRemaining - 1, 0)

            guard let replacement = opponentBoard.promoteFirstBenchToActive() else {
                finishGame(
                    title: "You Win!",
                    message: "\(attackerName) knocked out \(knockedOut?.name ?? "the opponent's Active Pokemon")."
                )
                return
            }

            battleMessage = "\(attackerName) knocked out \(knockedOut?.name ?? "the opponent's Active Pokemon"). \(replacement.name) moved up from the opponent bench."
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
