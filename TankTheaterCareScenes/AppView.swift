import SwiftUI

struct AppView: View {
    @EnvironmentObject private var store: CareSceneStore
    @State private var path: [AppRoute] = []

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                HomeView(path: $path)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .studio(let draft): CareSceneStudioView(path: $path, initialDraft: draft)
                        case .detail(let id): CareSceneDetailView(path: $path, recordID: id)
                        case .paywall: PaywallView()
                        case .privacy: PrivacyBoundaryView()
                        }
                    }
            }
            .tabItem { Label("Scenes", systemImage: "water.waves") }

            NavigationStack { SettingsPrivacyView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
