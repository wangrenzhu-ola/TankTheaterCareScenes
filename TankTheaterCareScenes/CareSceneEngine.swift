import Foundation

struct CareSceneEngine {
    static func evaluate(_ draft: CareSceneDraft, previous: CareSceneRecord?) -> (cue: CareCue, reason: String, waterHex: String, comparison: String) {
        guard draft.readingMode == .tested else {
            return (.watch, "No test strip was logged today, so keep the scene visible and retest before changing care.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        if draft.ammonia >= 0.25 || draft.nitrate >= 40 || draft.pH < 6.6 || draft.pH > 8.2 || draft.observation == .lowAppetite {
            return (.intervene, "One reading or behavior is outside the beginner-safe watch band; do a small water check and avoid diagnosis claims.", "D9534F", comparisonCopy(newCue: .intervene, previous: previous))
        }
        if draft.nitrate >= 25 || draft.observation == .cloudyWater || draft.observation == .algaeBloom || draft.observation == .plantsPale {
            return (.watch, "The tank is mostly usable, but this observation deserves a follow-up scene before the next feeding.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        return (.stable, "Readings and visible behavior line up with a calm tank moment.", "2FA872", comparisonCopy(newCue: .stable, previous: previous))
    }

    static func comparisonCopy(newCue: CareCue, previous: CareSceneRecord?) -> String {
        guard let previous else { return "First saved Care Scene — the next one will compare cue changes here." }
        if previous.cue == newCue { return "Still \(newCue.rawValue): newest cue matches \(previous.title)." }
        return "Changed from \(previous.cue.rawValue) to \(newCue.rawValue) since \(previous.title)."
    }

    static func aiFallbackNote(for draft: CareSceneDraft) -> String {
        "Manual cue: \(draft.observation.rawValue.lowercased()) in a \(draft.tankStage.rawValue.lowercased()). Keep this note editable; no AI route or save happens without your confirmation."
    }
}
