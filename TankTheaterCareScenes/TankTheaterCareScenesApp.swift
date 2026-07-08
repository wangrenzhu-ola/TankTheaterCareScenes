import SwiftUI

@main
struct TankTheaterCareScenesApp: App {
    @StateObject private var store = CareSceneStore()
    @StateObject private var premiumStore = PremiumStore()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(store)
                .environmentObject(premiumStore)
        }
    }
}
