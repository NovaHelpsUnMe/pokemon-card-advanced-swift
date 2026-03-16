import SwiftUI

struct BattleActionBarView: View {
    let handTitle: String
    let attackTitle: String
    let canAttack: Bool
    let canStartBattle: Bool
    let canRestart: Bool
    let onHand: () -> Void
    let onAttack: () -> Void
    let onStartBattle: () -> Void
    let onRestart: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ActionBarButton(title: handTitle, systemImage: "square.stack.3d.up", fill: Color.white.opacity(0.92), foreground: .primary, action: onHand)

            ActionBarButton(title: attackTitle, systemImage: "bolt.fill", fill: canAttack ? Color.red : Color.gray.opacity(0.5), foreground: .white, isDisabled: !canAttack, action: onAttack)

            if canStartBattle {
                ActionBarButton(title: "Start Battle", systemImage: "flag.checkered", fill: Color.blue, foreground: .white, action: onStartBattle)
            }

            if canRestart {
                ActionBarButton(title: "Restart", systemImage: "arrow.clockwise", fill: Color.white.opacity(0.92), foreground: .primary, action: onRestart)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -2)
    }
}

private struct ActionBarButton: View {
    let title: String
    let systemImage: String
    let fill: Color
    let foreground: Color
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.headline)

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .padding(.horizontal, 8)
            .background(fill)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .disabled(isDisabled)
    }
}
