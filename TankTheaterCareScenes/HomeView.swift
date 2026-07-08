import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CareSceneStore
    @EnvironmentObject private var premium: PremiumStore
    @Binding var path: [AppRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HeroTankStage(cue: store.records.first?.cue ?? .watch, title: "TankTheater", subtitle: store.latestComparison)
                    .accessibilityLabel("Miniature tank stage with water cue color and saved Care Scene comparison")

                if store.records.isEmpty {
                    EmptyCareSceneView(create: startCareScene)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Care Scenes").font(.title2.bold())
                        ForEach(store.records) { record in
                            Button { path.append(.detail(record.id)) } label: { CareSceneCard(record: record) }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Open Care Scene \(record.title), cue \(record.cue.rawValue)")
                        }
                    }
                }

                PremiumPreviewCard(isUnlocked: premium.isPremiumUnlocked) { path.append(.paywall) }
                Button("Start your first Care Scene.", action: startCareScene)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel("Start your first Care Scene")
                Button("Privacy and AI boundary") { path.append(.privacy) }
                    .accessibilityLabel("Open Privacy and AI boundary sheet")
            }
            .padding()
        }
        .navigationTitle("Care Scenes")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("New") { startCareScene() } } }
        .task { await premium.loadProducts() }
    }

    private func startCareScene() {
        store.startNewDraft()
        path.append(.studio(.blank))
    }
}

private struct EmptyCareSceneView: View {
    let create: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start your first Care Scene.").font(.title2.bold())
            Text("Log a tank stage, water readings, and one living-scene observation. TankTheater will render Stable, Watch, or Intervene without making veterinary claims.")
            MiniCueComparison(newText: "No saved cue yet", previousText: "Comparison appears after your first save")
            Button("Create Care Scene", action: create).buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}
