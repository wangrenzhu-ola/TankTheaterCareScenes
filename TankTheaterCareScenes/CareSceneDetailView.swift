import SwiftUI

struct CareSceneDetailView: View {
    @EnvironmentObject private var store: CareSceneStore
    @Binding var path: [AppRoute]
    let recordID: UUID
    @State private var showDeleteConfirm = false
    @State private var showExport = false

    var record: CareSceneRecord? { store.records.first { $0.id == recordID } }

    var body: some View {
        ScrollView {
            if let record {
                VStack(alignment: .leading, spacing: 20) {
                    HeroTankStage(cue: record.cue, title: record.title, subtitle: record.cueReason)
                    CareSceneCard(record: record)
                    MiniCueComparison(newText: "Newest: \(record.cue.rawValue)", previousText: CareSceneEngine.comparisonCopy(newCue: record.cue, previous: store.records.dropFirst().first))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Care note").font(.headline)
                        Text(record.careNote.isEmpty ? "No extra note saved." : record.careNote)
                    }
                    HStack {
                        Button("Edit") { path.append(.studio(CareSceneDraft(record: record))) }
                        Button("Export") { showExport = true }
                        Button("Delete", role: .destructive) { showDeleteConfirm = true }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ContentUnavailableView("Care Scene unavailable", systemImage: "exclamationmark.triangle", description: Text("This Care Scene may have been deleted locally."))
            }
        }
        .navigationTitle("Care Scene Detail")
        .alert("Delete this Care Scene?", isPresented: $showDeleteConfirm, presenting: record) { record in
            Button("Delete", role: .destructive) { store.delete(record); path.removeAll() }
            Button("Cancel", role: .cancel) { }
        } message: { record in Text("Remove \(record.title) from local storage?") }
        .sheet(isPresented: $showExport) { if let record { ExportSheet(text: store.exportText(for: record)) } }
    }
}

private struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let text: String
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Local export preview").font(.title2.bold())
                Text(text).padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                Text("Premium unlocks longer history export. This preview never uploads data.").font(.footnote).foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}
