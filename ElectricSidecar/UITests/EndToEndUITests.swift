import XCTest

final class EndToEndUITests: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testLoginButtonEnablesOnceUsernameAndPasswordAreEntered() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertFalse(app.buttons["Log in"].isEnabled)

    app.textFields["Email"].tap()
    app.keys["t"].tap()
    app.keys["more"].tap()
    app.keys["@"].tap()
    app.keys["more"].tap()
    app.keys["g"].tap()
    app.keys["more"].tap()
    app.keys["."].tap()
    app.keys["more"].tap()
    app.keys["c"].tap()
    app.keys["o"].tap()
    app.buttons["Done"].tap()

    XCTAssertFalse(app.buttons["Log in"].isEnabled)

    app.secureTextFields["Password"].tap()
    app.keys["a"].tap()
    app.keys["b"].tap()
    app.keys["c"].tap()
    app.buttons["Done"].tap()

    XCTAssertTrue(app.buttons["Log in"].isEnabled)
    app.buttons["Log in"].tap()
  }
}

