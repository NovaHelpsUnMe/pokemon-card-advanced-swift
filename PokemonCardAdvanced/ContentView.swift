import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.95, blue: 0.78),
                    Color(red: 0.98, green: 0.86, blue: 0.56)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Pokemon Card Advanced")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(viewModel.turnLabel)
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.75))
                            .clipShape(Capsule())
                    }

                    PokemonCardView(title: "Opponent", battlePokemon: viewModel.opponent)
                    PokemonCardView(title: "Player", battlePokemon: viewModel.player)

                    BattleControlsView(
                        message: viewModel.battleMessage,
                        attackButtonTitle: viewModel.attackButtonTitle,
                        isAttackEnabled: viewModel.isPlayerTurn,
                        isGameOver: viewModel.isGameOver,
                        resultTitle: viewModel.resultTitle,
                        resultMessage: viewModel.resultMessage,
                        onAttack: viewModel.playerAttack,
                        onRestart: viewModel.restartGame
                    )
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
