import Combine
import Foundation
import SwiftUI

enum BattleTurn {
    case player
    case opponent
}

enum GamePhase {
    case setup
    case draw
    case action
    case attack
    case gameOver

    var label: String {
        switch self {
        case .setup:
            return "Setup Phase"
        case .draw:
            return "Draw Phase"
        case .action:
            return "Action Phase"
        case .attack:
            return "Attack Phase"
        case .gameOver:
            return "Game Over"
        }
    }
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
    private var hasCompletedOpeningPlayerTurn = false

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
        gamePhase.label
    }

    var isPlayerTurn: Bool {
        currentTurn == .player && isBattleInProgress
    }

    var isPlayerActionPhase: Bool {
        currentTurn == .player && gamePhase == .action && !isGameOver
    }

    var isGameOver: Bool {
        gamePhase == .gameOver
    }

    var turnLabel: String {
        switch currentTurn {
        case .player:
            return "Player Turn"
        case .opponent:
            return "Opponent Turn"
        }
    }

    var primaryActionButtonTitle: String {
        if canEndPlayerTurn {
            return "End Turn"
        }

        "\(playerBoard.active?.attackName ?? "Attack")"
    }

    var isPrimaryActionEnabled: Bool {
        canEndPlayerTurn || canPlayerAttack
    }

    var shouldShowTurnLabel: Bool {
        isBattleInProgress
    }

    var canPlayerAttack: Bool {
        isPlayerActionPhase &&
        playerBoard.active != nil &&
        !isOpeningPlayerTurnAttackBlocked
    }

    var canEndPlayerTurn: Bool {
        isPlayerActionPhase && isOpeningPlayerTurnAttackBlocked
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
        case .draw:
            return isPlayerTurn ? "Drawing your turn card." : "Opponent is drawing a card."
        case .action:
            if isPlayerActionPhase {
                return canEndPlayerTurn
                    ? "Play a card to your bench if needed, then end the turn."
                    : "Play a card to your bench or attack when ready."
            }

            return "Wait for the opponent's turn to finish."
        case .attack:
            return isPlayerTurn ? "Resolving your attack." : "Opponent attack in progress."
        case .gameOver:
            return "The battle is over."
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
        (gamePhase == .setup || isPlayerActionPhase)
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
        case .draw:
            return "Drawing"
        case .action:
            return isPlayerActionPhase ? "No Action" : "Opponent Turn"
        case .attack:
            return "Resolving"
        case .gameOver:
            return "Unavailable"
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

        hasCompletedOpeningPlayerTurn = false
        beginTurn(for: .player, after: "Setup complete. \(playerBoard.active?.name ?? "Your active Pokemon") goes first.")
    }

    func performPrimaryAction() {
        if canEndPlayerTurn {
            endPlayerTurn()
            return
        }

        playerAttack()
    }

    func playerAttack() {
        guard
            canPlayerAttack,
            let attacker = playerBoard.active,
            var defender = opponentBoard.active
        else {
            return
        }

        gamePhase = .attack
        defender.currentHP = updatedHP(afterAttacking: attacker, defender: defender)
        opponentBoard.replaceActive(defender)

        if defender.currentHP == 0 {
            resolveKnockout(on: .opponent, attackerName: attacker.name)
            return
        }

        beginTurn(for: .opponent, after: "\(attacker.name) used \(attacker.attackName) for \(attacker.damage) damage.")
    }

    func restartGame() {
        playerBoard = PlayerBoard(title: "Player", deck: playerDeckSeed.map { BattlePokemon(pokemon: $0) })
        opponentBoard = PlayerBoard(title: "Opponent", deck: opponentDeckSeed.map { BattlePokemon(pokemon: $0) })
        gamePhase = .setup
        currentTurn = .player
        hasCompletedOpeningPlayerTurn = false
        playerBoard.drawCards(5)
        opponentBoard.drawCards(5)
        autoSetupOpponentBoard()
        battleMessage = "Choose an active Pokemon from your opening hand."
        resultTitle = nil
        resultMessage = nil
    }

    private var isBattleInProgress: Bool {
        switch gamePhase {
        case .draw, .action, .attack:
            return true
        case .setup, .gameOver:
            return false
        }
    }

    private var isOpeningPlayerTurnAttackBlocked: Bool {
        currentTurn == .player && !hasCompletedOpeningPlayerTurn
    }

    private func scheduleOpponentAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.opponentTakeAction()
        }
    }

    private func opponentTakeAction() {
        guard !isGameOver, currentTurn == .opponent, gamePhase == .action else { return }

        gamePhase = .attack
        opponentAttack()
    }

    private func opponentAttack() {
        guard
            !isGameOver,
            currentTurn == .opponent,
            gamePhase == .attack,
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
        beginTurn(for: .player, after: "\(attacker.name) used \(attacker.attackName) for \(attacker.damage) damage.")
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

    private func beginTurn(for turn: BattleTurn, after message: String) {
        currentTurn = turn
        gamePhase = .draw

        let drawMessage: String?

        switch turn {
        case .player:
            drawMessage = playerBoard.drawCards(1).first.map { "You drew \($0.name)." }
        case .opponent:
            drawMessage = opponentBoard.drawCards(1).first.map { "Opponent drew \($0.name)." }
            refillOpponentBenchIfPossible()
        }

        enterActionPhase(for: turn, after: appendedMessage(message, with: drawMessage))
    }

    private func enterActionPhase(for turn: BattleTurn, after message: String) {
        currentTurn = turn
        gamePhase = .action

        if turn == .player && isOpeningPlayerTurnAttackBlocked {
            battleMessage = appendedMessage(message, with: "You can't attack on your first turn.")
            return
        }

        battleMessage = message

        if turn == .opponent {
            scheduleOpponentAction()
        }
    }

    private func endPlayerTurn() {
        guard canEndPlayerTurn else { return }

        hasCompletedOpeningPlayerTurn = true
        beginTurn(for: .opponent, after: "You ended your opening turn.")
    }

    private func appendedMessage(_ base: String, with suffix: String?) -> String {
        guard let suffix, !suffix.isEmpty else { return base }
        guard !base.isEmpty else { return suffix }
        return "\(base) \(suffix)"
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
            beginTurn(for: .player, after: battleMessage)

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
            beginTurn(for: .opponent, after: battleMessage)
        }
    }

    private func finishGame(title: String, message: String) {
        resultTitle = title
        resultMessage = message
        gamePhase = .gameOver
        battleMessage = message
    }
}
