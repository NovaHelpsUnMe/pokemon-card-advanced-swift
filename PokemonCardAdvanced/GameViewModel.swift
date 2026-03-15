import Combine
import Foundation
import SwiftUI

enum BattleTurn {
    case player
    case opponent
}

// GameViewModel controls the battle rules, changing game state, and Live Activity updates.
@MainActor
final class GameViewModel: ObservableObject {
    @Published var player: BattlePokemon
    @Published var opponent: BattlePokemon
    @Published var currentTurn: BattleTurn = .player
    @Published var battleMessage: String
    @Published var resultTitle: String?
    @Published var resultMessage: String?

    private let startingPlayer: Pokemon
    private let startingOpponent: Pokemon
    private let liveActivityManager = BattleLiveActivityManager()

    init(playerPokemon: Pokemon = playerStarter, opponentPokemon: Pokemon = opponentStarter) {
        startingPlayer = playerPokemon
        startingOpponent = opponentPokemon
        player = BattlePokemon(pokemon: playerPokemon)
        opponent = BattlePokemon(pokemon: opponentPokemon)
        battleMessage = "\(playerPokemon.name) is ready to battle \(opponentPokemon.name)!"

        Task {
            await startLiveActivity()
        }
    }

    var isPlayerTurn: Bool {
        currentTurn == .player && !isGameOver
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
        "\(player.attackName) Attack"
    }

    func playerAttack() {
        guard isPlayerTurn else { return }

        opponent.currentHP = updatedHP(afterAttacking: player, defender: opponent)

        if opponent.currentHP == 0 {
            finishGame(
                title: "You Win!",
                message: "\(player.name) knocked out \(opponent.name)!",
                battleStatus: "win",
                lastMoveName: player.attackName,
                lastDamage: player.damage
            )
            return
        }

        currentTurn = .opponent
        battleMessage = "\(player.name) used \(player.attackName) for \(player.damage) damage."

        Task {
            await updateLiveActivity(
                lastMoveName: player.attackName,
                lastDamage: player.damage,
                battleStatus: "active"
            )
        }

        scheduleOpponentTurn()
    }

    func restartGame() {
        player = BattlePokemon(pokemon: startingPlayer)
        opponent = BattlePokemon(pokemon: startingOpponent)
        currentTurn = .player
        battleMessage = "\(player.name) is ready to battle \(opponent.name)!"
        resultTitle = nil
        resultMessage = nil

        Task {
            await startLiveActivity()
        }
    }

    private func scheduleOpponentTurn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.opponentAttack()
        }
    }

    private func opponentAttack() {
        guard !isGameOver else { return }

        player.currentHP = updatedHP(afterAttacking: opponent, defender: player)

        if player.currentHP == 0 {
            finishGame(
                title: "You Lose",
                message: "\(opponent.name) knocked out \(player.name).",
                battleStatus: "lose",
                lastMoveName: opponent.attackName,
                lastDamage: opponent.damage
            )
            return
        }

        currentTurn = .player
        battleMessage = "\(opponent.name) used \(opponent.attackName) for \(opponent.damage) damage."

        Task {
            await updateLiveActivity(
                lastMoveName: opponent.attackName,
                lastDamage: opponent.damage,
                battleStatus: "active"
            )
        }
    }

    private func updatedHP(afterAttacking attacker: BattlePokemon, defender: BattlePokemon) -> Int {
        max(defender.currentHP - attacker.damage, 0)
    }

    private func finishGame(
        title: String,
        message: String,
        battleStatus: String,
        lastMoveName: String,
        lastDamage: Int
    ) {
        resultTitle = title
        resultMessage = message
        battleMessage = message

        Task {
            await liveActivityManager.endBattle(
                playerHP: player.currentHP,
                opponentHP: opponent.currentHP,
                lastMoveName: lastMoveName,
                lastDamage: lastDamage,
                currentTurnLabel: turnLabel,
                battleStatus: battleStatus
            )
        }
    }

    private func startLiveActivity() async {
        await liveActivityManager.startBattle(
            playerName: player.name,
            opponentName: opponent.name,
            playerHP: player.currentHP,
            opponentHP: opponent.currentHP,
            currentTurnLabel: turnLabel
        )
    }

    private func updateLiveActivity(
        lastMoveName: String,
        lastDamage: Int,
        battleStatus: String
    ) async {
        await liveActivityManager.updateBattle(
            playerHP: player.currentHP,
            opponentHP: opponent.currentHP,
            lastMoveName: lastMoveName,
            lastDamage: lastDamage,
            currentTurnLabel: turnLabel,
            battleStatus: battleStatus
        )
    }
}
