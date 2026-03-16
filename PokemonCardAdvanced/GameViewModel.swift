import Combine
import Foundation
import SwiftUI

enum BattleTurn {
    case player
    case opponent
}

// GameViewModel controls the battle rules and published game state.
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
    init(playerPokemon: Pokemon = playerStarter, opponentPokemon: Pokemon = opponentStarter) {
        startingPlayer = playerPokemon
        startingOpponent = opponentPokemon
        player = BattlePokemon(pokemon: playerPokemon)
        opponent = BattlePokemon(pokemon: opponentPokemon)
        battleMessage = "\(playerPokemon.name) is ready to battle \(opponentPokemon.name)!"
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
                message: "\(player.name) knocked out \(opponent.name)!"
            )
            return
        }

        currentTurn = .opponent
        battleMessage = "\(player.name) used \(player.attackName) for \(player.damage) damage."

        scheduleOpponentTurn()
    }

    func restartGame() {
        player = BattlePokemon(pokemon: startingPlayer)
        opponent = BattlePokemon(pokemon: startingOpponent)
        currentTurn = .player
        battleMessage = "\(player.name) is ready to battle \(opponent.name)!"
        resultTitle = nil
        resultMessage = nil
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
                message: "\(opponent.name) knocked out \(player.name)."
            )
            return
        }

        currentTurn = .player
        battleMessage = "\(opponent.name) used \(opponent.attackName) for \(opponent.damage) damage."
    }

    private func updatedHP(afterAttacking attacker: BattlePokemon, defender: BattlePokemon) -> Int {
        max(defender.currentHP - attacker.damage, 0)
    }

    private func finishGame(title: String, message: String) {
        resultTitle = title
        resultMessage = message
        battleMessage = message
    }
}
