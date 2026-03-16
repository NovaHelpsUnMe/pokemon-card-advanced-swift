import SwiftUI

struct BattleActionBarView: View {
    let handButtonTitle: String
    let primaryActionButtonTitle: String
    let isPrimaryActionEnabled: Bool
    let retreatButtonTitle: String
    let isRetreatEnabled: Bool
    let showsRetreatButton: Bool
    let canStartBattle: Bool
    let isGameOver: Bool
    let onHandTapped: () -> Void
    let onRetreatTapped: () -> Void
    let onPrimaryActionTapped: () -> Void
    let onStartBattleTapped: () -> Void
    let onRestartTapped: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                actionButton(
                    title: handButtonTitle,
                    background: Color.white.opacity(0.92),
                    foreground: .primary,
                    action: onHandTapped
                )

                if showsRetreatButton {
                    actionButton(
                        title: retreatButtonTitle,
                        background: isRetreatEnabled ? Color.blue : Color.gray,
                        foreground: .white,
                        isEnabled: isRetreatEnabled,
                        action: onRetreatTapped
                    )
                }
            }

            if !canStartBattle && !isGameOver {
                actionButton(
                    title: primaryActionButtonTitle,
                    background: isPrimaryActionEnabled ? Color.red : Color.gray,
                    foreground: .white,
                    isEnabled: isPrimaryActionEnabled,
                    action: onPrimaryActionTapped
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
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
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
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isEnabled)
    }
}
