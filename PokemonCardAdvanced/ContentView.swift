import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var isHandSheetPresented = false
    @State private var inspectedCard: BattlePokemon?

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

            GeometryReader { proxy in
                let contentHeight = proxy.size.height

                VStack(spacing: 10) {
                    Text("Pokemon Card Advanced")
                        .font(.title2)
                        .fontWeight(.bold)

                    BattleHeaderView(
                        title: viewModel.opponentBoard.title,
                        deckCount: viewModel.opponentBoard.deckCount,
                        discardCount: viewModel.opponentBoard.discardCount,
                        prizeCount: viewModel.opponentBoard.prizesRemaining
                    )

                    PokemonCardView(
                        title: "Opponent Active",
                        battlePokemon: viewModel.opponentBoard.active,
                        emphasis: .compact
                    )

                    BenchRowView(
                        title: "Opponent Bench",
                        cards: viewModel.opponentBoard.bench,
                        maxSlots: viewModel.opponentBoard.maxBenchSize
                    )

                    BattleControlsView(
                        phaseLabel: viewModel.phaseLabel,
                        message: viewModel.battleMessage,
                        resultTitle: viewModel.resultTitle,
                        resultMessage: viewModel.resultMessage
                    )

                    PokemonCardView(
                        title: "Player Active",
                        battlePokemon: viewModel.playerBoard.active,
                        emphasis: .regular
                    )

                    BenchRowView(
                        title: "Your Bench",
                        cards: viewModel.playerBoard.bench,
                        maxSlots: viewModel.playerBoard.maxBenchSize
                    )

                    BattleHeaderView(
                        title: viewModel.playerBoard.title,
                        deckCount: viewModel.playerBoard.deckCount,
                        discardCount: viewModel.playerBoard.discardCount,
                        prizeCount: viewModel.playerBoard.prizesRemaining
                    )
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .frame(width: proxy.size.width, height: contentHeight, alignment: .top)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BattleActionBarView(
                handTitle: viewModel.handButtonTitle,
                attackTitle: viewModel.attackButtonTitle,
                canAttack: viewModel.isAttackEnabled,
                canStartBattle: viewModel.canStartBattle,
                canRestart: viewModel.canRestartFromBar,
                onHand: { isHandSheetPresented = true },
                onAttack: viewModel.playerAttack,
                onStartBattle: viewModel.startBattle,
                onRestart: viewModel.restartGame
            )
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .background(Color.clear)
        }
        .sheet(isPresented: $isHandSheetPresented) {
            HandSheetView(
                title: viewModel.handSheetTitle,
                subtitle: viewModel.handSheetSubtitle,
                cards: viewModel.playerBoard.hand,
                canMakeActive: viewModel.canAssignPlayerActive,
                canBench: viewModel.canBenchPlayerCard,
                actionSummary: viewModel.cardActionSummary,
                onMakeActive: { card in
                    viewModel.placePlayerActive(cardID: card.id)
                    if viewModel.playerBoard.hand.isEmpty || viewModel.playerBoard.active != nil {
                        isHandSheetPresented = false
                    }
                },
                onBench: { card in
                    viewModel.placePlayerBench(cardID: card.id)
                },
                onInspect: { card in
                    inspectedCard = card
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $inspectedCard) { card in
            CardDetailSheetView(battlePokemon: card)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}
