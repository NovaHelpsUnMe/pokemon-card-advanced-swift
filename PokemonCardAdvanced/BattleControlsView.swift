import SwiftUI

struct BattleControlsView: View {
    let phaseLabel: String
    let message: String
    let attackButtonTitle: String
    let isAttackEnabled: Bool
    let canStartBattle: Bool
    let isGameOver: Bool
    let resultTitle: String?
    let resultMessage: String?
    let onAttack: () -> Void
    let onStartBattle: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(phaseLabel)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.75))
                .clipShape(Capsule())

            // Battle log lets the player follow each move.
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 18))

            // Main attack button for the player's turn.
            Button(action: onAttack) {
                Text(attackButtonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAttackEnabled ? Color.red : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(!isAttackEnabled)

            if canStartBattle && !isGameOver {
                Button("Start Battle", action: onStartBattle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            if isGameOver {
                VStack(spacing: 10) {
                    Text(resultTitle ?? "Battle Over")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(resultMessage ?? "")
                        .multilineTextAlignment(.center)

                    Button("Restart Game", action: onRestart)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }

            if !isGameOver {
                Button("Restart Game", action: onRestart)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Capsule())
            }
        }
    }
}
