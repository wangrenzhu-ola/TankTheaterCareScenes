import XCTest
@testable import TankTheaterCareScenes

final class CareSceneEngineTests: XCTestCase {
    func testInterveneCueForUnsafeReading() {
        var draft = CareSceneDraft.blank
        draft.title = "Cloudy bowl"
        draft.ammonia = 0.5
        let result = CareSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .intervene)
        XCTAssertTrue(result.reason.contains("outside"))
    }

    func testNotTestedStaysWatchAndManual() {
        var draft = CareSceneDraft.blank
        draft.readingMode = .notTested
        let result = CareSceneEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .watch)
        XCTAssertTrue(result.reason.contains("No test strip"))
    }
}
