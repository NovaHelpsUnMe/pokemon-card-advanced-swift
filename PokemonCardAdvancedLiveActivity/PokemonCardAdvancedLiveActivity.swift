import ActivityKit
import SwiftUI
import WidgetKit

struct PokemonCardAdvancedLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BattleActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(context.attributes.playerName)
                        .font(.headline)
                    Spacer()
                    Text("HP \(context.state.playerHP)")
                        .font(.headline)
                }

                HStack {
                    Text(context.attributes.opponentName)
                        .font(.headline)
                    Spacer()
                    Text("HP \(context.state.opponentHP)")
                        .font(.headline)
                }

                Divider()

                Text("Last Move: \(context.state.lastMoveName)")
                    .font(.subheadline)
                Text("Damage: \(context.state.lastDamage)")
                    .font(.subheadline)
                Text("Turn: \(context.state.currentTurnLabel)")
                    .font(.subheadline)
                Text("Status: \(context.state.battleStatus.capitalized)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding()
            .activityBackgroundTint(Color.yellow.opacity(0.25))
            .activitySystemActionForegroundColor(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.playerName)
                            .font(.headline)
                        Text("HP \(context.state.playerHP)")
                            .font(.caption)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.attributes.opponentName)
                            .font(.headline)
                        Text("HP \(context.state.opponentHP)")
                            .font(.caption)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        Text("Last Move: \(context.state.lastMoveName)")
                            .font(.subheadline)
                        Text("Damage: \(context.state.lastDamage)")
                            .font(.subheadline)
                        Text("\(context.state.currentTurnLabel) • \(context.state.battleStatus.capitalized)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
            } compactLeading: {
                Text("\(shortName(for: context.attributes.playerName))/\(shortName(for: context.attributes.opponentName))")
                    .font(.caption2)
            } compactTrailing: {
                if context.state.lastDamage > 0 {
                    Text("-\(context.state.lastDamage)")
                        .font(.caption2)
                } else {
                    Text("HP")
                        .font(.caption2)
                }
            } minimal: {
                Text("VS")
                    .font(.caption2)
            }
            .widgetURL(URL(string: "pokemoncardadvanced://battle"))
            .keylineTint(.orange)
        }
    }

    private func shortName(for fullName: String) -> String {
        String(fullName.prefix(1)).uppercased()
    }
}

@main
struct PokemonCardAdvancedLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        PokemonCardAdvancedLiveActivity()
    }
}
