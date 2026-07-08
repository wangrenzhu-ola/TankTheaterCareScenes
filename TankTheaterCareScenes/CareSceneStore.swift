import Foundation
import Combine

@MainActor
final class CareSceneStore: ObservableObject {
    @Published private(set) var records: [CareSceneRecord] = []
    @Published var draft: CareSceneDraft = .blank { didSet { persistDraft() } }
    @Published var privacyChoice = PrivacyChoice() { didSet { persistPrivacy() } }
    @Published var lastErrorMessage: String?
    @Published var lastSuccessMessage: String?
    @Published var simulateNextSaveFailure = false

    private let recordsURL: URL
    private let draftKey = "TankTheaterCareScenes.draft"
    private let privacyKey = "TankTheaterCareScenes.privacy"

    init(fileManager: FileManager = .default) {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        recordsURL = docs.appendingPathComponent("tanktheater-care-scenes.json")
        load()
    }

    var latestComparison: String {
        guard let newest = records.first else { return "No saved comparison yet. Save the first Care Scene to start a local history." }
        return CareSceneEngine.comparisonCopy(newCue: newest.cue, previous: records.dropFirst().first)
    }

    func startNewDraft() { draft = .blank }

    func applyOptionalSuggestion() {
        draft.careNote = CareSceneEngine.aiFallbackNote(for: draft)
    }

    @discardableResult
    func save(_ incoming: CareSceneDraft) throws -> CareSceneRecord {
        guard !incoming.trimmedTitle.isEmpty else { throw CareSceneSaveError.emptyTitle }
        if simulateNextSaveFailure {
            simulateNextSaveFailure = false
            lastErrorMessage = CareSceneSaveError.simulatedFailure.localizedDescription
            throw CareSceneSaveError.simulatedFailure
        }
        let previous = records.first(where: { $0.id != incoming.id })
        let evaluation = CareSceneEngine.evaluate(incoming, previous: previous)
        let now = Date()
        let record = CareSceneRecord(
            id: incoming.id ?? UUID(),
            title: incoming.trimmedTitle,
            tankStage: incoming.tankStage,
            readingMode: incoming.readingMode,
            pH: incoming.pH,
            ammonia: incoming.ammonia,
            nitrate: incoming.nitrate,
            observation: incoming.observation,
            careNote: incoming.careNote,
            cue: evaluation.cue,
            cueReason: evaluation.reason,
            waterCueHex: evaluation.waterHex,
            createdAt: records.first(where: { $0.id == incoming.id })?.createdAt ?? now,
            updatedAt: now
        )
        if let index = records.firstIndex(where: { $0.id == record.id }) { records[index] = record } else { records.insert(record, at: 0) }
        records.sort { $0.updatedAt > $1.updatedAt }
        draft = CareSceneDraft(record: record)
        do { try persistRecords() } catch { throw CareSceneSaveError.storageFailure(error.localizedDescription) }
        lastErrorMessage = nil
        lastSuccessMessage = "Care Scene saved."
        return record
    }

    func delete(_ record: CareSceneRecord) {
        records.removeAll { $0.id == record.id }
        try? persistRecords()
    }

    func exportText(for record: CareSceneRecord) -> String {
        "\(record.title) — \(record.cue.rawValue): \(record.cueReason)"
    }

    private func load() {
        if let data = try? Data(contentsOf: recordsURL), let decoded = try? JSONDecoder.tankTheater.decode([CareSceneRecord].self, from: data) { records = decoded.sorted { $0.updatedAt > $1.updatedAt } }
        if let data = UserDefaults.standard.data(forKey: draftKey), let decoded = try? JSONDecoder.tankTheater.decode(CareSceneDraft.self, from: data) { draft = decoded }
        if let data = UserDefaults.standard.data(forKey: privacyKey), let decoded = try? JSONDecoder.tankTheater.decode(PrivacyChoice.self, from: data) { privacyChoice = decoded }
        if let pending = UserDefaults.standard.string(forKey: "pendingCareSceneTitle"), !pending.isEmpty {
            draft.title = pending
            UserDefaults.standard.removeObject(forKey: "pendingCareSceneTitle")
        }
    }

    private func persistRecords() throws {
        let data = try JSONEncoder.tankTheater.encode(records)
        try data.write(to: recordsURL, options: [.atomic])
    }

    private func persistDraft() {
        if let data = try? JSONEncoder.tankTheater.encode(draft) { UserDefaults.standard.set(data, forKey: draftKey) }
    }

    private func persistPrivacy() {
        if let data = try? JSONEncoder.tankTheater.encode(privacyChoice) { UserDefaults.standard.set(data, forKey: privacyKey) }
    }
}

struct PrivacyChoice: Codable, Hashable {
    var optionalAIRoutingAllowed = false
    var seedExamplesVisible = true
    var localExportAllowed = true
}

extension JSONEncoder {
    static var tankTheater: JSONEncoder { let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601; return encoder }
}

extension JSONDecoder {
    static var tankTheater: JSONDecoder { let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601; return decoder }
}
