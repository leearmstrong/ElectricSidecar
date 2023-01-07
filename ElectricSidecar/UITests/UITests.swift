import XCTest

final class UITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testExample() throws {
    let app = XCUIApplication()
    app.launch()
  }
}

