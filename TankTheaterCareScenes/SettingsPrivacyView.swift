import SwiftUI

struct SettingsPrivacyView: View {
    @EnvironmentObject private var store: CareSceneStore
    @EnvironmentObject private var premium: PremiumStore

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Allow optional AI routing after review", isOn: $store.privacyChoice.optionalAIRoutingAllowed)
                Toggle("Show labeled local starter examples", isOn: $store.privacyChoice.seedExamplesVisible)
                Toggle("Allow local export previews", isOn: $store.privacyChoice.localExportAllowed)
                NavigationLink("Read Privacy / AI boundary") { PrivacyBoundaryView() }
            }
            Section("Premium boundary") {
                LabeledContent("Premium unlocked", value: premium.isPremiumUnlocked ? "Yes" : "No")
                Text("The first one-tank Care Scene loop is never paywalled. Premium only adds multiple tanks, longer history, export, and themes.")
            }
            Section("Data controls") {
                Text("Care Scenes, drafts, privacy choices, and entitlement flags are stored on this device. Delete controls are available on each Care Scene detail.")
            }
        }
        .navigationTitle("Settings")
    }
}

struct PrivacyBoundaryView: View {
    var body: some View {
        List {
            Section("Local-first storage") {
                Text("Care Scenes, readings, observations, drafts, premium state, and privacy choices stay on device unless you export them.")
            }
            Section("Optional AI boundary") {
                Text("Manual rules fully deliver v0. Optional note cleanup is Kimi-ready for a future user-supplied route, but this app contains no API keys and never saves AI text automatically.")
            }
            Section("Review notes") {
                Text("TankTheater does not diagnose fish health, promise emergency care, claim sensor data, or publish community content.")
            }
        }
        .navigationTitle("Privacy / AI")
    }
}
