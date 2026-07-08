import SwiftUI

struct CareSceneStudioView: View {
    @EnvironmentObject private var store: CareSceneStore
    @Binding var path: [AppRoute]
    @State private var draft: CareSceneDraft
    @State private var showSuggestionSheet = false
    @State private var localError: String?
    @State private var savedRecordID: UUID?

    init(path: Binding<[AppRoute]>, initialDraft: CareSceneDraft) {
        _path = path
        _draft = State(initialValue: initialDraft)
    }

    var body: some View {
        Form {
            if let localError {
                Section { ErrorBanner(message: localError, retry: save) }
            }
            Section("Care Scene identity") {
                TextField("Care Scene name", text: $draft.title)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Care Scene name")
                Picker("Tank stage", selection: $draft.tankStage) {
                    ForEach(TankStage.allCases) { Text($0.rawValue).tag($0) }
                }
                MiniTankStage(stage: draft.tankStage, cue: previewCue)
                    .frame(height: 150)
                    .accessibilityLabel("Miniature tank stage preview")
            }
            Section("Water cue") {
                Picker("Reading mode", selection: $draft.readingMode) {
                    ForEach(ReadingMode.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                if draft.readingMode == .tested {
                    Stepper("pH: \(draft.pH, specifier: "%.1f")", value: $draft.pH, in: 6.0...8.8, step: 0.1)
                    Stepper("Ammonia: \(draft.ammonia, specifier: "%.2f") ppm", value: $draft.ammonia, in: 0...1.0, step: 0.05)
                    Stepper("Nitrate: \(draft.nitrate, specifier: "%.0f") ppm", value: $draft.nitrate, in: 0...80, step: 5)
                } else {
                    Text("Manual not-tested state keeps the Care Scene usable and reminds you to retest before changing care.")
                }
            }
            Section("Living-scene observation") {
                Picker("Observation", selection: $draft.observation) {
                    ForEach(ObservationType.allCases) { Text($0.rawValue).tag($0) }
                }
                TextEditor(text: $draft.careNote)
                    .frame(minHeight: 96)
                    .accessibilityLabel("Care Scene note")
                Button("Optional editable note cleanup") { showSuggestionSheet = true }
                    .accessibilityLabel("Open optional AI/manual fallback suggestion")
            }
            Section("Cue preview") {
                let preview = CareSceneEngine.evaluate(draft, previous: store.records.first)
                CuePill(cue: preview.cue, reason: preview.reason)
                Text(preview.comparison).font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button("Save this Care Scene.", action: save)
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Save this Care Scene")
                Button("Simulate save failure for recovery") { store.simulateNextSaveFailure = true; save() }
                    .accessibilityLabel("Simulate Care Scene save failure")
            }
        }
        .navigationTitle(draft.id == nil ? "Care Scene Studio" : "Review your Care Scene changes.")
        .sheet(isPresented: $showSuggestionSheet) { SuggestionSheet(draft: $draft) }
        .onDisappear { store.draft = draft }
    }

    private var previewCue: CareCue { CareSceneEngine.evaluate(draft, previous: store.records.first).cue }

    private func save() {
        do {
            let record = try store.save(draft)
            savedRecordID = record.id
            localError = nil
            path.append(.detail(record.id))
        } catch {
            localError = error.localizedDescription
        }
    }
}

private struct SuggestionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: CareSceneDraft

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("AI unavailable or declined? Manual flow still works.").font(.title2.bold())
                Text("This local suggestion is editable and skipped unless you tap Apply. No factory Kimi key, secret, or autonomous save is used.")
                Text(CareSceneEngine.aiFallbackNote(for: draft)).padding().background(Color(hex: "EAF7F3"), in: RoundedRectangle(cornerRadius: 18))
                Spacer()
                Button("Apply editable note") { draft.careNote = CareSceneEngine.aiFallbackNote(for: draft); dismiss() }
                    .buttonStyle(.borderedProminent)
                Button("Keep manual note") { dismiss() }
            }
            .padding()
            .navigationTitle("Manual fallback")
        }
    }
}
