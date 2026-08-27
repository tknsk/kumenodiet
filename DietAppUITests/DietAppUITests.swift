import XCTest

final class DietAppUITests: XCTestCase {
    func testLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.state == .runningForeground)
    }
}
