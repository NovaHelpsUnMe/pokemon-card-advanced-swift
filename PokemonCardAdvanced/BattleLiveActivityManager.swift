import ActivityKit
import Foundation

// Handles starting, updating, and ending the Live Activity from the app target.
@MainActor
final class BattleLiveActivityManager {
    private var activity: Activity<BattleActivityAttributes>?

    func startBattle(
        playerName: String,
        opponentName: String,
        playerHP: Int,
        opponentHP: Int,
        currentTurnLabel: String
    ) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        await endExistingActivitiesIfNeeded()

        let attributes = BattleActivityAttributes(
            playerName: playerName,
            opponentName: opponentName
        )

        let state = BattleActivityAttributes.ContentState(
            playerHP: playerHP,
            opponentHP: opponentHP,
            lastMoveName: "Battle Start",
            lastDamage: 0,
            currentTurnLabel: currentTurnLabel,
            battleStatus: "active"
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }

    func updateBattle(
        playerHP: Int,
        opponentHP: Int,
        lastMoveName: String,
        lastDamage: Int,
        currentTurnLabel: String,
        battleStatus: String
    ) async {
        guard let activity else { return }

        let updatedState = BattleActivityAttributes.ContentState(
            playerHP: playerHP,
            opponentHP: opponentHP,
            lastMoveName: lastMoveName,
            lastDamage: lastDamage,
            currentTurnLabel: currentTurnLabel,
            battleStatus: battleStatus
        )

        await activity.update(.init(state: updatedState, staleDate: nil))
    }

    func endBattle(
        playerHP: Int,
        opponentHP: Int,
        lastMoveName: String,
        lastDamage: Int,
        currentTurnLabel: String,
        battleStatus: String
    ) async {
        guard let activity else { return }

        let finalState = BattleActivityAttributes.ContentState(
            playerHP: playerHP,
            opponentHP: opponentHP,
            lastMoveName: lastMoveName,
            lastDamage: lastDamage,
            currentTurnLabel: currentTurnLabel,
            battleStatus: battleStatus
        )

        await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .default)
        self.activity = nil
    }

    private func endExistingActivitiesIfNeeded() async {
        for existingActivity in Activity<BattleActivityAttributes>.activities {
            await existingActivity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
