import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var isHandSheetPresented = false
    @State private var selectedCard: CardDetailItem?
    @State private var isSelectingRetreatTarget = false

    var body: some View {
        GeometryReader { geometry in
            let topInset = max(geometry.safeAreaInsets.top, 10)
            let compactHeight = geometry.size.height < 780
            let boardSpacing: CGFloat = compactHeight ? 8 : 10
            let horizontalPadding: CGFloat = geometry.size.width <= 375 ? 10 : 12
            let scrollContentBottomInset: CGFloat = 128 + geometry.safeAreaInsets.bottom

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

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: boardSpacing) {
                        boardTitle
                        opponentSection
                        battleStatusPanel
                        playerSection
                        Color.clear
                            .frame(height: scrollContentBottomInset)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, topInset)
                    .padding(.bottom, compactHeight ? 10 : 14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BattleActionBarView(
                handButtonTitle: viewModel.playerHandButtonTitle,
                primaryActionButtonTitle: viewModel.primaryActionButtonTitle,
                isPrimaryActionEnabled: viewModel.isPrimaryActionEnabled,
                retreatButtonTitle: isSelectingRetreatTarget ? "Cancel Retreat" : "Retreat",
                isRetreatEnabled: isSelectingRetreatTarget || viewModel.canRetreat,
                showsRetreatButton: viewModel.shouldShowRetreatButton,
                canStartBattle: viewModel.canStartBattle,
                isGameOver: viewModel.isGameOver,
                onHandTapped: { isHandSheetPresented = true },
                onRetreatTapped: toggleRetreatSelection,
                onPrimaryActionTapped: viewModel.performPrimaryAction,
                onStartBattleTapped: viewModel.startBattle,
                onRestartTapped: viewModel.restartGame
            )
            .padding(.horizontal, 12)
            .padding(.top, 6)
            .padding(.bottom, 6)
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
                },
                onAttachEnergy: { card in
                    viewModel.attachPlayerEnergy(to: card.id)
                },
                onEvolve: { card, target in
                    viewModel.evolvePlayerPokemon(cardID: card.id, targetID: target.id)
                },
                onPlayTrainer: { card in
                    viewModel.playTrainer(cardID: card.id)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedCard) { card in
            CardDetailSheetView(item: card) {
                selectedCard = nil
            }
        }
        .onChange(of: viewModel.canRetreat) { canRetreat in
            if !canRetreat {
                isSelectingRetreatTarget = false
            }
        }
        .onChange(of: viewModel.shouldShowRetreatButton) { isVisible in
            if !isVisible {
                isSelectingRetreatTarget = false
            }
        }
    }

    private var boardTitle: some View {
        Text("Pokemon Card Advanced")
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
    }

    private var opponentSection: some View {
        VStack(spacing: 7) {
            BattleHeaderView(
                label: viewModel.opponentBoard.title,
                deckCount: viewModel.opponentVisibleDeckCount,
                discardCount: viewModel.opponentVisibleDiscardCount,
                energyCount: viewModel.opponentBoard.energyHandCount,
                prizeCount: viewModel.opponentPrizesRemaining
            )

            activeCardSection(
                title: "Opponent Active",
                card: viewModel.opponentBoard.active
            )

            benchSection(cards: viewModel.opponentBoard.bench, maxSlots: viewModel.opponentBoard.maxBenchSize)
        }
        .padding(11)
        .background(boardPanelBackground)
    }

    private var playerSection: some View {
        VStack(spacing: 7) {
            activeCardSection(
                title: "Player Active",
                card: viewModel.playerBoard.active
            )

            benchSection(cards: viewModel.playerBoard.bench, maxSlots: viewModel.playerBoard.maxBenchSize)

            BattleHeaderView(
                label: viewModel.playerBoard.title,
                deckCount: viewModel.playerVisibleDeckCount,
                discardCount: viewModel.playerVisibleDiscardCount,
                energyCount: viewModel.playerBoard.energyHandCount,
                prizeCount: viewModel.playerPrizesRemaining
            )
        }
        .padding(11)
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

            if isSelectingRetreatTarget {
                Text("Choose a Benched Pokemon to become your new Active Pokemon.")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let resultMessage = viewModel.resultMessage {
                Text(resultMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
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
        viewModel.phaseLabel
    }

    private var battleTurnText: String? {
        guard viewModel.shouldShowTurnLabel else {
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
                    selectedCard = .boardPokemon(card)
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
            selectableCardIDs: isSelectingRetreatTarget ? Set(viewModel.availablePlayerRetreatTargets.map(\.id)) : [],
            onSelectCard: { card in
                handleBenchSelection(card)
            }
        )
    }

    private func inspectHandCard(_ card: BattleCard) {
        isHandSheetPresented = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedCard = .handCard(card)
        }
    }

    private func toggleRetreatSelection() {
        guard viewModel.shouldShowRetreatButton else {
            return
        }

        if isSelectingRetreatTarget {
            isSelectingRetreatTarget = false
            return
        }

        guard viewModel.canRetreat else {
            return
        }

        isSelectingRetreatTarget = true
    }

    private func handleBenchSelection(_ card: BattlePokemon) {
        if isSelectingRetreatTarget && viewModel.availablePlayerRetreatTargets.contains(card) {
            viewModel.performPlayerRetreat(to: card.id)
            isSelectingRetreatTarget = false
            return
        }

        selectedCard = .boardPokemon(card)
    }
}

#Preview {
    ContentView()
}
