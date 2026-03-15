import ActivityKit
import Foundation

// Matching Live Activity model used by the widget extension target.
struct BattleActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var playerHP: Int
        var opponentHP: Int
        var lastMoveName: String
        var lastDamage: Int
        var currentTurnLabel: String
        var battleStatus: String
    }

    var playerName: String
    var opponentName: String
}
