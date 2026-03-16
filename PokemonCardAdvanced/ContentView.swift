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
                    }

                    VStack(spacing: 14) {
                        BoardStatusView(
                            title: viewModel.opponentBoard.title,
                            deckCount: viewModel.opponentBoard.deckCount,
                            handCount: viewModel.opponentBoard.handCount,
                            discardCount: viewModel.opponentBoard.discardCount
                        )

                        PokemonCardView(title: "Opponent Active", battlePokemon: viewModel.opponentBoard.active)
                        BenchRowView(cards: viewModel.opponentBoard.bench, maxSlots: viewModel.opponentBoard.maxBenchSize)
                    }
                    .padding()
                    .background(Color.white.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 26))

                    VStack(spacing: 14) {
                        BoardStatusView(
                            title: viewModel.playerBoard.title,
                            deckCount: viewModel.playerBoard.deckCount,
                            handCount: viewModel.playerBoard.handCount,
                            discardCount: viewModel.playerBoard.discardCount
                        )

                        PokemonCardView(title: "Player Active", battlePokemon: viewModel.playerBoard.active)
                        BenchRowView(cards: viewModel.playerBoard.bench, maxSlots: viewModel.playerBoard.maxBenchSize)
                    }
                    .padding()
                    .background(Color.white.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 26))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Player Hand")
                            .font(.title3)
                            .fontWeight(.bold)

                        if viewModel.playerBoard.hand.isEmpty {
                            Text("No cards in hand.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(viewModel.playerBoard.hand) { card in
                                        HandCardView(
                                            battlePokemon: card,
                                            showMakeActive: viewModel.canAssignPlayerActive(card),
                                            showBench: viewModel.canBenchPlayerCard(card),
                                            onMakeActive: { viewModel.placePlayerActive(cardID: card.id) },
                                            onBench: { viewModel.placePlayerBench(cardID: card.id) }
                                        )
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 26))

                    BattleControlsView(
                        phaseLabel: viewModel.phaseLabel,
                        message: viewModel.battleMessage,
                        attackButtonTitle: viewModel.attackButtonTitle,
                        isAttackEnabled: viewModel.isPlayerTurn,
                        canStartBattle: viewModel.canStartBattle,
                        isGameOver: viewModel.isGameOver,
                        resultTitle: viewModel.resultTitle,
                        resultMessage: viewModel.resultMessage,
                        onAttack: viewModel.playerAttack,
                        onStartBattle: viewModel.startBattle,
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
