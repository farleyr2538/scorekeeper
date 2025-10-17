//
//  ScoreKeeperUITests.swift
//  ScoreKeeperUITests
//
//  Created by Robert Farley on 04/08/2025.
//

import XCTest
import Foundation

final class ScoreKeeperUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testGame() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["Create Game"]/*[[".otherElements.buttons[\"Create Game\"]",".buttons[\"Create Game\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCUIScreen.main.screenshot()
        app/*@START_MENU_TOKEN@*/.buttons["Add players"]/*[[".otherElements.buttons[\"Add players\"]",".buttons[\"Add players\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let nameField = app.textFields["Name"]
        
        let players = ["Rob", "Kate", "Vnesh", "Nikhil"]
        for player in players {
            nameField.typeText(player)
            app/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".scrollViews.buttons.firstMatch",".otherElements.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements[\"Done\"].buttons.firstMatch",".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".otherElements.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        for _ in 0..<20 {
            
            // add a round
            app/*@START_MENU_TOKEN@*/.buttons["Add new round"]/*[[".otherElements.buttons[\"Add new round\"]",".buttons[\"Add new round\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            
            let winner = Int.random(in: 0..<players.count)
            
            for index in 0..<players.count {
                let elementsQuery = app.textFields.matching(identifier: "0")
                let element = elementsQuery.element(boundBy: index)
                element.tap()
                var score : Int
                if index == winner {
                    score = 0
                } else {
                    score = Int.random(in: 1...35)
                }
                element.typeText(String(score))
            }
            
            app.buttons["Add"].tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["Finish"]/*[[".otherElements.buttons[\"Finish\"]",".buttons[\"Finish\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    @MainActor
    func testMagnifier() throws {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["Create Game"]/*[[".otherElements.buttons[\"Create Game\"]",".buttons[\"Create Game\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add players"]/*[[".otherElements.buttons[\"Add players\"]",".buttons[\"Add players\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Jimmy"]/*[[".otherElements.staticTexts[\"Jimmy\"]",".staticTexts[\"Jimmy\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Timmy"]/*[[".otherElements.staticTexts[\"Timmy\"]",".staticTexts[\"Timmy\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements[\"Done\"].buttons",".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".otherElements.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element = app/*@START_MENU_TOKEN@*/.buttons["Add new round"]/*[[".otherElements.buttons[\"Add new round\"]",".buttons[\"Add new round\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.tap()
        
        let elementsQuery = app.textFields.matching(identifier: "0")
        let element2 = elementsQuery.element(boundBy: 0)
        element2.typeText("0")
        
        let element3 = elementsQuery.element(boundBy: 1)
        element3.tap()
        element3.tap()
        element3.typeText("5")
        
        let element4 = app/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".otherElements.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element4.tap()
        element.tap()
        element2.tap()
        app/*@START_MENU_TOKEN@*/.textFields["5"]/*[[".otherElements.textFields[\"5\"]",".textFields[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText("5")
        element3.tap()
        element3.tap()
        element3.typeText("0")
        element4.tap()
        app.cells/*@START_MENU_TOKEN@*/.firstMatch/*[[".containing(.other, identifier: nil).firstMatch",".firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        
        let element5 = app/*@START_MENU_TOKEN@*/.buttons["plus.magnifyingglass"]/*[[".otherElements[\"plus.magnifyingglass\"].buttons",".otherElements",".buttons[\"Zoom In\"]",".buttons[\"plus.magnifyingglass\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element5.tap()
        element5.doubleTap()
        element5.tap()
        XCUIDevice.shared.press(.home)
        
        let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboardApp/*@START_MENU_TOKEN@*/.images["record.circle"]/*[[".otherElements",".images[\"Screen Recording\"]",".images[\"record.circle\"]",".images"],[[[-1,2],[-1,1],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
