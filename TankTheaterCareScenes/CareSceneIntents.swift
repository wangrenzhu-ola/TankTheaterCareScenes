import AppIntents
import Foundation

struct DraftCareSceneIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft Care Scene"
    static var description = IntentDescription("Creates an editable TankTheater Care Scene draft title and opens the app. It never saves autonomously.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Care Scene Title") var title: String

    init() { self.title = "" }
    init(title: String) { self.title = title }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        UserDefaults.standard.set(title, forKey: "pendingCareSceneTitle")
        return .result(dialog: "Editable Care Scene draft ready. Review it before saving.")
    }
}

struct TankTheaterShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: DraftCareSceneIntent(), phrases: ["Draft a \(.applicationName) care scene"], shortTitle: "Draft Care Scene", systemImageName: "water.waves")
    }
}
