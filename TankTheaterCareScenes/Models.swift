import Foundation
import SwiftUI

struct CareSceneRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var tankStage: TankStage
    var readingMode: ReadingMode
    var pH: Double
    var ammonia: Double
    var nitrate: Double
    var observation: ObservationType
    var careNote: String
    var cue: CareCue
    var cueReason: String
    var waterCueHex: String
    var createdAt: Date
    var updatedAt: Date
}

enum TankStage: String, CaseIterable, Codable, Identifiable, Hashable {
    case plantedBowl = "Planted bowl"
    case nanoReef = "Nano reef"
    case goldfishCorner = "Goldfish corner"
    case quarantineCup = "Quarantine cup"

    var id: String { rawValue }
    var accentHex: String {
        switch self {
        case .plantedBowl: return "3BAA8C"
        case .nanoReef: return "2D7DD2"
        case .goldfishCorner: return "E69F35"
        case .quarantineCup: return "8F96A3"
        }
    }
}

enum ReadingMode: String, CaseIterable, Codable, Identifiable, Hashable {
    case tested = "Tested today"
    case notTested = "Not tested"
    var id: String { rawValue }
}

enum ObservationType: String, CaseIterable, Codable, Identifiable, Hashable {
    case activeFish = "Fish active"
    case plantsPale = "Plants pale"
    case cloudyWater = "Cloudy water"
    case algaeBloom = "Algae bloom"
    case lowAppetite = "Low appetite"
    var id: String { rawValue }
}

enum CareCue: String, CaseIterable, Codable, Identifiable, Hashable {
    case stable = "Stable"
    case watch = "Watch"
    case intervene = "Intervene"

    var id: String { rawValue }
    var color: Color {
        switch self {
        case .stable: return Color(hex: "2FA872")
        case .watch: return Color(hex: "D9911A")
        case .intervene: return Color(hex: "D9534F")
        }
    }
}

struct CareSceneDraft: Codable, Hashable {
    var id: UUID?
    var title: String
    var tankStage: TankStage
    var readingMode: ReadingMode
    var pH: Double
    var ammonia: Double
    var nitrate: Double
    var observation: ObservationType
    var careNote: String
    var lastGeneratedCue: CareCue?
    var lastGeneratedReason: String?

    static let blank = CareSceneDraft(
        id: nil,
        title: "",
        tankStage: .plantedBowl,
        readingMode: .tested,
        pH: 7.2,
        ammonia: 0.0,
        nitrate: 15.0,
        observation: .activeFish,
        careNote: "",
        lastGeneratedCue: nil,
        lastGeneratedReason: nil
    )

    init(record: CareSceneRecord) {
        id = record.id
        title = record.title
        tankStage = record.tankStage
        readingMode = record.readingMode
        pH = record.pH
        ammonia = record.ammonia
        nitrate = record.nitrate
        observation = record.observation
        careNote = record.careNote
        lastGeneratedCue = record.cue
        lastGeneratedReason = record.cueReason
    }

    init(id: UUID?, title: String, tankStage: TankStage, readingMode: ReadingMode, pH: Double, ammonia: Double, nitrate: Double, observation: ObservationType, careNote: String, lastGeneratedCue: CareCue?, lastGeneratedReason: String?) {
        self.id = id
        self.title = title
        self.tankStage = tankStage
        self.readingMode = readingMode
        self.pH = pH
        self.ammonia = ammonia
        self.nitrate = nitrate
        self.observation = observation
        self.careNote = careNote
        self.lastGeneratedCue = lastGeneratedCue
        self.lastGeneratedReason = lastGeneratedReason
    }

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
}

enum CareSceneSaveError: LocalizedError, Equatable {
    case emptyTitle
    case simulatedFailure
    case storageFailure(String)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Name this Care Scene before saving."
        case .simulatedFailure:
            return "Couldn’t save this Care Scene. Try again."
        case .storageFailure(let message):
            return "Couldn’t save this Care Scene: \(message)"
        }
    }
}

enum AppRoute: Hashable {
    case studio(CareSceneDraft)
    case detail(UUID)
    case paywall
    case privacy
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
