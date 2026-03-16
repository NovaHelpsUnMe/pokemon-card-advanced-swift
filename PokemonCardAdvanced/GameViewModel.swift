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
    var deck: [BattleCard]
    var hand: [BattleCard] = []
    var energyHandCount: Int = 0
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

    mutating func drawEnergy(_ count: Int = 1) {
        guard count > 0 else { return }
        energyHandCount += count
    }

    mutating func attachEnergy(to cardID: UUID) -> BattlePokemon? {
        guard energyHandCount > 0 else { return nil }

        if var activeCard = active, activeCard.id == cardID {
            activeCard.attachEnergy()
            active = activeCard
            energyHandCount -= 1
            return activeCard
        }

        guard let benchIndex = bench.firstIndex(where: { $0.id == cardID }) else {
            return nil
        }

        bench[benchIndex].attachEnergy()
        energyHandCount -= 1
        return bench[benchIndex]
    }

    mutating func replaceActive(_ card: BattlePokemon?) {
        active = card
    }

    mutating func replaceBenchCard(targetID: UUID, with battlePokemon: BattlePokemon) {
        guard let index = bench.firstIndex(where: { $0.id == targetID }) else { return }
        bench[index] = battlePokemon
    }

    mutating func spendActiveEnergy(_ amount: Int) -> Bool {
        guard amount >= 0, var activeCard = active, activeCard.spendEnergy(amount) else {
            return false
        }

        active = activeCard
        return true
    }

    mutating func retreatActive(toBenchCardID cardID: UUID) -> BattlePokemon? {
        guard let currentActive = active,
              let benchIndex = bench.firstIndex(where: { $0.id == cardID }) else {
            return nil
        }

        let promoted = bench.remove(at: benchIndex)
        active = nil
        bench.append(currentActive)
        active = promoted
        return promoted
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

@MainActor
final class GameViewModel: ObservableObject {
    private static let initialPrizeCount = 6

    @Published var playerBoard: PlayerBoard
    @Published var opponentBoard: PlayerBoard
    @Published var gamePhase: GamePhase = .setup
    @Published var currentTurn: BattleTurn = .player
    @Published var battleMessage: String
    @Published var resultTitle: String?
    @Published var resultMessage: String?
    @Published var hasPlayerAttachedEnergyThisTurn = false
    @Published var hasPlayerRetreatedThisTurn = false
    @Published var playerPrizeCount = GameViewModel.initialPrizeCount
    @Published var opponentPrizeCount = GameViewModel.initialPrizeCount

    private let playerDeckSeed: [CardDefinition]
    private let opponentDeckSeed: [CardDefinition]
    private var hasCompletedOpeningPlayerTurn = false

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
        gamePhase.label
    }

    var isBattleInProgress: Bool {
        switch gamePhase {
        case .draw, .action, .attack:
            return true
        case .setup, .gameOver:
            return false
        }
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

        guard let active = playerBoard.active else {
            return "Attack"
        }

        return "\(active.attackName) (\(active.attackEnergyCost))"
    }

    var isPrimaryActionEnabled: Bool {
        canEndPlayerTurn || canPlayerAttack
    }

    var shouldShowTurnLabel: Bool {
        isBattleInProgress
    }

    var canPlayerAttack: Bool {
        isPlayerActionPhase &&
        playerBoard.active?.hasEnoughEnergyForAttack == true &&
        !isOpeningPlayerTurnAttackBlocked
    }

    var canEndPlayerTurn: Bool {
        isPlayerActionPhase && isOpeningPlayerTurnAttackBlocked
    }

    var availablePlayerRetreatTargets: [BattlePokemon] {
        guard isPlayerActionPhase,
              !hasPlayerRetreatedThisTurn,
              playerBoard.active?.hasEnoughEnergyToRetreat == true,
              !playerBoard.bench.isEmpty else {
            return []
        }

        return playerBoard.bench
    }

    var availablePlayerEnergyTargets: [BattlePokemon] {
        guard isPlayerActionPhase,
              !hasPlayerAttachedEnergyThisTurn,
              playerBoard.energyHandCount > 0 else {
            return []
        }

        return [playerBoard.active].compactMap { $0 } + playerBoard.bench
    }

    var canRetreat: Bool {
        !availablePlayerRetreatTargets.isEmpty
    }

    var shouldShowRetreatButton: Bool {
        isPlayerActionPhase && !isGameOver
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
        case .draw:
            return isPlayerTurn ? "Drawing your turn card." : "Opponent is drawing a card."
        case .action:
            if isPlayerActionPhase {
                return canEndPlayerTurn
                    ? "Play a trainer, evolve a Pokemon, bench a Basic Pokemon, or attach 1 Basic Energy, then end the turn."
                    : "Play a trainer, evolve a Pokemon, bench a Basic Pokemon, attach 1 Basic Energy, retreat, or attack when ready."
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
        playerPrizeCount
    }

    var opponentVisibleDeckCount: Int {
        opponentBoard.deckCount
    }

    var opponentVisibleDiscardCount: Int {
        opponentBoard.discardCount
    }

    var opponentPrizesRemaining: Int {
        opponentPrizeCount
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
        (gamePhase == .setup || isPlayerActionPhase)
    }

    func playerActiveEvolutionTarget(for card: BattleCard) -> BattlePokemon? {
        guard isPlayerActionPhase,
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
        guard isPlayerActionPhase,
              let evolution = card.pokemon,
              evolution.stage != .basic,
              playerBoard.hand.contains(where: { $0.id == card.id }) else {
            return []
        }

        return playerBoard.bench.filter { $0.canEvolve(with: evolution) }
    }

    func canPlayTrainer(_ card: BattleCard) -> Bool {
        guard isPlayerActionPhase,
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

    func canAttachPlayerEnergy(to card: BattlePokemon) -> Bool {
        availablePlayerEnergyTargets.contains(where: { $0.id == card.id })
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
            case .draw, .action, .attack, .gameOver:
                return isPlayerActionPhase ? "Needs matching Pokemon" : "Unavailable"
            }
        }

        if card.trainer != nil {
            switch gamePhase {
            case .setup:
                return "Play during battle"
            case .draw, .action, .attack, .gameOver:
                return isPlayerActionPhase ? "No legal target" : "Unavailable"
            }
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
        guard let card = playerBoard.moveHandCardToActive(
            cardID: cardID,
            countsAsPlayedThisTurn: gamePhase != .setup
        ) else {
            return
        }

        battleMessage = "\(card.name) is now your active Pokemon. Add bench Pokemon or start the battle."
    }

    func placePlayerBench(cardID: UUID) {
        guard let card = playerBoard.moveHandCardToBench(
            cardID: cardID,
            countsAsPlayedThisTurn: gamePhase != .setup
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
        guard isPlayerActionPhase,
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

        hasCompletedOpeningPlayerTurn = false
        hasPlayerAttachedEnergyThisTurn = false
        hasPlayerRetreatedThisTurn = false
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

    func performPlayerRetreat(to benchCardID: UUID) {
        guard canRetreat,
              let previousActive = playerBoard.active,
              playerBoard.spendActiveEnergy(previousActive.retreatCost),
              let promoted = playerBoard.retreatActive(toBenchCardID: benchCardID) else {
            return
        }

        hasPlayerRetreatedThisTurn = true
        let retreatText = previousActive.retreatCost == 0
            ? "\(previousActive.name) retreated."
            : "\(previousActive.name) spent \(previousActive.retreatCost) Energy and retreated."
        battleMessage = "\(retreatText) \(promoted.name) moved up from your bench."
    }

    func attachPlayerEnergy(to cardID: UUID) {
        guard isPlayerActionPhase,
              !hasPlayerAttachedEnergyThisTurn,
              let updatedCard = playerBoard.attachEnergy(to: cardID) else {
            return
        }

        hasPlayerAttachedEnergyThisTurn = true

        if updatedCard.hasEnoughEnergyForAttack {
            battleMessage = "Attached 1 Basic Energy to \(updatedCard.name). It is ready to use \(updatedCard.attackName)."
        } else {
            battleMessage = "Attached 1 Basic Energy to \(updatedCard.name). It now has \(updatedCard.attachedEnergy)/\(updatedCard.attackEnergyCost) Energy for \(updatedCard.attackName)."
        }
    }

    func restartGame() {
        playerBoard = PlayerBoard(title: "Player", deck: Self.makeDeck(from: playerDeckSeed))
        opponentBoard = PlayerBoard(title: "Opponent", deck: Self.makeDeck(from: opponentDeckSeed))
        playerPrizeCount = GameViewModel.initialPrizeCount
        opponentPrizeCount = GameViewModel.initialPrizeCount
        gamePhase = .setup
        currentTurn = .player
        hasCompletedOpeningPlayerTurn = false
        hasPlayerAttachedEnergyThisTurn = false
        hasPlayerRetreatedThisTurn = false
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

        guard attacker.hasEnoughEnergyForAttack else {
            refillOpponentBenchIfPossible()
            beginTurn(for: .player, after: "\(attacker.name) does not have enough Energy to attack.")
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

    private func beginTurn(for turn: BattleTurn, after message: String) {
        currentTurn = turn
        gamePhase = .draw

        if turn == .player {
            playerBoard.clearPlayedThisTurnFlags()
            hasPlayerAttachedEnergyThisTurn = false
            hasPlayerRetreatedThisTurn = false
            playerBoard.drawEnergy(1)
        } else {
            opponentBoard.clearPlayedThisTurnFlags()
            opponentBoard.drawEnergy(1)
        }

        let drawMessage: String?
        let energyMessage: String
        var followUpMessage: String?

        switch turn {
        case .player:
            drawMessage = playerBoard.drawCards(1).first.map { "You drew \($0.name)." }
            energyMessage = "You drew 1 Basic Energy."
        case .opponent:
            drawMessage = opponentBoard.drawCards(1).first.map { "Opponent drew \($0.name)." }
            refillOpponentBenchIfPossible()
            energyMessage = "Opponent drew 1 Basic Energy."
            followUpMessage = opponentAutoAttachEnergy()
        }

        let updatedMessage = appendedMessage(
            appendedMessage(appendedMessage(message, with: drawMessage), with: energyMessage),
            with: followUpMessage
        )
        enterActionPhase(for: turn, after: updatedMessage)
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
            let knockedOutName = playerBoard.discardActive()?.name ?? "your active Pokemon"
            let opponentPrizesRemaining = takePrize(for: .opponent)

            if opponentPrizesRemaining == 0 {
                finishGame(
                    title: "You Lose",
                    message: "\(attackerName) knocked out \(knockedOutName) and took the final prize."
                )
                return
            }

            guard let replacement = playerBoard.promoteFirstBenchToActive() else {
                finishGame(
                    title: "You Lose",
                    message: "\(attackerName) knocked out \(knockedOutName)."
                )
                return
            }

            battleMessage = "\(attackerName) knocked out \(knockedOutName). Opponent took a prize. \(replacement.name) moved up from your bench."
            beginTurn(for: .player, after: battleMessage)

        case .opponent:
            let knockedOutName = opponentBoard.discardActive()?.name ?? "the opponent's active Pokemon"
            let playerPrizesRemaining = takePrize(for: .player)

            if playerPrizesRemaining == 0 {
                finishGame(
                    title: "You Win!",
                    message: "\(attackerName) knocked out \(knockedOutName) and took your final prize."
                )
                return
            }

            guard let replacement = opponentBoard.promoteFirstBenchToActive() else {
                finishGame(
                    title: "You Win!",
                    message: "\(attackerName) knocked out \(knockedOutName)."
                )
                return
            }

            battleMessage = "\(attackerName) knocked out \(knockedOutName). You took a prize. \(replacement.name) moved up from the opponent bench."
            beginTurn(for: .opponent, after: battleMessage)
        }
    }

    private func takePrize(for side: BattleTurn) -> Int {
        switch side {
        case .player:
            playerPrizeCount = max(playerPrizeCount - 1, 0)
            return playerPrizeCount
        case .opponent:
            opponentPrizeCount = max(opponentPrizeCount - 1, 0)
            return opponentPrizeCount
        }
    }

    private func finishGame(title: String, message: String) {
        resultTitle = title
        resultMessage = message
        gamePhase = .gameOver
        battleMessage = message
    }

    private func opponentAutoAttachEnergy() -> String? {
        guard opponentBoard.energyHandCount > 0 else {
            return nil
        }

        let targetID = opponentBoard.active?.id ?? opponentBoard.bench.first?.id

        guard let targetID,
              let updatedCard = opponentBoard.attachEnergy(to: targetID) else {
            return nil
        }

        return "Opponent attached 1 Basic Energy to \(updatedCard.name)."
    }
}
