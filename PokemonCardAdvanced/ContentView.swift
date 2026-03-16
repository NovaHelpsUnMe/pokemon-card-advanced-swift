import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var isHandSheetPresented = false
    @State private var selectedCard: BattlePokemon?

    var body: some View {
        GeometryReader { geometry in
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

                VStack(spacing: 10) {
                    boardTitle
                    opponentSection
                    battleStatusPanel
                    playerSection
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 12)
                .padding(.top, max(geometry.safeAreaInsets.top, 12))
                .padding(.bottom, 8)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BattleActionBarView(
                handButtonTitle: viewModel.playerHandButtonTitle,
                attackButtonTitle: viewModel.attackButtonTitle,
                isAttackEnabled: viewModel.isAttackButtonEnabled,
                canStartBattle: viewModel.canStartBattle,
                isGameOver: viewModel.isGameOver,
                onHandTapped: { isHandSheetPresented = true },
                onAttackTapped: viewModel.playerAttack,
                onStartBattleTapped: viewModel.startBattle,
                onRestartTapped: viewModel.restartGame
            )
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color.clear)
        }
        .sheet(isPresented: $isHandSheetPresented) {
            HandSheetView(
                viewModel: viewModel,
                onSelectCard: inspectHandCard,
                onMakeActive: { card in
                    viewModel.placePlayerActive(cardID: card.id)
                },
                onMoveToBench: { card in
                    viewModel.placePlayerBench(cardID: card.id)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedCard) { card in
            CardDetailSheetView(battlePokemon: card) {
                selectedCard = nil
            }
        }
    }

    private var boardTitle: some View {
        Text("Pokemon Card Advanced")
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private var opponentSection: some View {
        VStack(spacing: 8) {
            BattleHeaderView(
                label: viewModel.opponentBoard.title,
                deckCount: viewModel.opponentVisibleDeckCount,
                discardCount: viewModel.opponentVisibleDiscardCount,
                prizeCount: viewModel.opponentPrizesRemaining
            )

            activeCardSection(
                title: "Opponent Active",
                card: viewModel.opponentBoard.active
            )

            benchSection(cards: viewModel.opponentBoard.bench, maxSlots: viewModel.opponentBoard.maxBenchSize)
        }
        .padding(12)
        .background(boardPanelBackground)
    }

    private var playerSection: some View {
        VStack(spacing: 8) {
            activeCardSection(
                title: "Player Active",
                card: viewModel.playerBoard.active
            )

            benchSection(cards: viewModel.playerBoard.bench, maxSlots: viewModel.playerBoard.maxBenchSize)

            BattleHeaderView(
                label: viewModel.playerBoard.title,
                deckCount: viewModel.playerVisibleDeckCount,
                discardCount: viewModel.playerVisibleDiscardCount,
                prizeCount: viewModel.playerPrizesRemaining
            )
        }
        .padding(12)
        .background(boardPanelBackground)
    }

    private var battleStatusPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                statusBadge(text: battlePhaseText)

                if let turnText = battleTurnText {
                    statusBadge(text: turnText)
                }

                Spacer()

                if let resultTitle = viewModel.resultTitle {
                    statusBadge(text: resultTitle, emphasized: true)
                }
            }

            Text(viewModel.battleMessage)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let resultMessage = viewModel.resultMessage {
                Text(resultMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var boardPanelBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.white.opacity(0.30))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
            )
    }

    private var battlePhaseText: String {
        switch viewModel.gamePhase {
        case .setup:
            return "Setup Phase"
        case .battle:
            return viewModel.isGameOver ? "Game Over" : "Battle Phase"
        }
    }

    private var battleTurnText: String? {
        guard viewModel.gamePhase == .battle, !viewModel.isGameOver else {
            return nil
        }

        return viewModel.turnLabel
    }

    private func statusBadge(text: String, emphasized: Bool = false) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(emphasized ? .white : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(emphasized ? Color.blue : Color.white.opacity(0.92))
            .clipShape(Capsule())
    }

    private func activeCardSection(title: String, card: BattlePokemon?) -> some View {
        Group {
            if let card {
                Button {
                    selectedCard = card
                } label: {
                    PokemonCardView(title: title, battlePokemon: card, displayStyle: .board)
                }
                .buttonStyle(.plain)
            } else {
                PokemonCardView(title: title, battlePokemon: nil, displayStyle: .board)
            }
        }
    }

    private func benchSection(cards: [BattlePokemon], maxSlots: Int) -> some View {
        BenchRowView(
            cards: cards,
            maxSlots: maxSlots,
            onSelectCard: { card in
                selectedCard = card
            }
        )
    }

    private func inspectHandCard(_ card: BattlePokemon) {
        isHandSheetPresented = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedCard = card
        }
    }
}

#Preview {
    ContentView()
}
