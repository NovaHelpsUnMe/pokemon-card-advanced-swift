import SwiftUI

struct BattleActionBarView: View {
    let handButtonTitle: String
    let attackButtonTitle: String
    let isAttackEnabled: Bool
    let canStartBattle: Bool
    let isGameOver: Bool
    let onHandTapped: () -> Void
    let onAttackTapped: () -> Void
    let onStartBattleTapped: () -> Void
    let onRestartTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                actionButton(
                    title: handButtonTitle,
                    background: Color.white.opacity(0.92),
                    foreground: .primary,
                    action: onHandTapped
                )

                actionButton(
                    title: attackButtonTitle,
                    background: isAttackEnabled ? Color.red : Color.gray,
                    foreground: .white,
                    isEnabled: isAttackEnabled,
                    action: onAttackTapped
                )
            }

            if canStartBattle && !isGameOver {
                actionButton(
                    title: "Start Battle",
                    background: Color.blue,
                    foreground: .white,
                    action: onStartBattleTapped
                )
            }

            if isGameOver {
                actionButton(
                    title: "Restart",
                    background: Color.blue,
                    foreground: .white,
                    action: onRestartTapped
                )
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    private func actionButton(
        title: String,
        background: Color,
        foreground: Color,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .disabled(!isEnabled)
    }
}
