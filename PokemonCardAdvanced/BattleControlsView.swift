import SwiftUI

struct BattleControlsView: View {
    let phaseLabel: String
    let message: String
    let resultTitle: String?
    let resultMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(phaseLabel)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.78))
                    .clipShape(Capsule())

                Spacer()

                if let resultTitle {
                    Text(resultTitle)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.red)
                }
            }

            Text(message)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let resultMessage, resultMessage != message {
                Text(resultMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}
