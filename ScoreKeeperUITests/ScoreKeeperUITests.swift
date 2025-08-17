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
        
        for _ in 0..<50 {
            
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
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
