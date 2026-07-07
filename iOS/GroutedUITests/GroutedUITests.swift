import XCTest

final class GroutedUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddNewEntryFlow() throws {
        app.buttons["addButton"].tap()
        let field = app.textFields["field_room"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("UI Test Entry")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() throws {
        app.buttons["addButton"].tap()
        let field = app.textFields["field_room"]
        XCTAssertTrue(field.waitForExistence(timeout: 2))
        field.tap()
        field.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Rating"].firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testPaywallTriggersAtFreeLimit() throws {
        for i in 0..<12 {
            app.buttons["addButton"].tap()
            let field = app.textFields["field_room"]
            if field.waitForExistence(timeout: 2) {
                field.tap()
                field.typeText("Entry \(i)")
                app.buttons["saveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["unlockButton"].waitForExistence(timeout: 3))
    }

    func testCancelDismissesForm() throws {
        app.buttons["addButton"].tap()
        app.buttons["cancelButton"].tap()
        XCTAssertTrue(app.buttons["addButton"].waitForExistence(timeout: 2))
    }

    func testSettingsOpensAndCloses() throws {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }
}
