//
//  ScoreKeeperUITests.swift
//  ScoreKeeperUITests
//
//  Created by Robert Farley on 04/08/2025.
//

import XCTest
import Foundation

final class ScoreKeeperUITests: XCTestCase {

    @MainActor
    func testRandomGame() throws {
        
        let app = XCUIApplication()
        app.activate()
        
        app/*@START_MENU_TOKEN@*/.buttons["Create Game"]/*[[".otherElements.buttons[\"Create Game\"]",".buttons[\"Create Game\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add players"]/*[[".otherElements.buttons[\"Add players\"]",".buttons[\"Add players\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
        
        let players = ["Rob", "Kate", "Vnesh", "Nikhil"]
        for player in players {
            let nameField = app.textFields["Name"]
            nameField.typeText(player)
            app/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".scrollViews.buttons.firstMatch",".otherElements.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements[\"Done\"].buttons.firstMatch",".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".otherElements.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let rounds = 5
        
        for _ in 0..<rounds {
            
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
        
        

    }
    
    @MainActor
    func testChartBugGame() {
        
        let data = [
            "Ollie": [0, 32, 0, 19, 15, 1, 4, 2, 15, 12],
            "Vnesh": [0, 10, 8, 0, 0, 33, 0, 32, 4, 0],
            "Rob": [0, 2, 12, 27, 9, 11, 12, 16, 13, 8],
            "Sach": [0, 10, 7, 17, 37, 21, 11, 12, 35, 4]
        ]
        let players = data.keys
        let scores = data.values // list of lists [ [player1's scores], [player2's scores], ... ]
        
        let app = XCUIApplication()
        app.activate()
        
        app/*@START_MENU_TOKEN@*/.buttons["Create Game"]/*[[".otherElements.buttons[\"Create Game\"]",".buttons[\"Create Game\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        // add players
        app/*@START_MENU_TOKEN@*/.buttons["Add players"]/*[[".otherElements.buttons[\"Add players\"]",".buttons[\"Add players\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        let addButton = app/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".otherElements.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        
        let names = ["Ollie", "Rob", "Vnesh", "Sach"]
        
        for name in names {
            app/*@START_MENU_TOKEN@*/.textFields["Name"]/*[[".otherElements",".textFields[\"Olli\"]",".textFields[\"Name\"]",".textFields"],[[[-1,2],[-1,1],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText(name)
            addButton.tap()
        }
        
        app.buttons["Done"].firstMatch.tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".otherElements.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        for round in 0..<scores.first!.count {
            
            let newRoundButton = app/*@START_MENU_TOKEN@*/.buttons["Add new round"]/*[[".otherElements.buttons[\"Add new round\"]",".buttons[\"Add new round\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
            newRoundButton.tap()
            
            let textFields = app.textFields.matching(identifier: "0").allElementsBoundByIndex

            // for each player, tap the corresponding index textfield and add their score
            for (index, player) in players.enumerated() {
                textFields[index].tap()
                let score = String(data[player]![round])
                textFields[index].typeText(score)
            }
            
            let addRoundButton = app.buttons["Add"].firstMatch
            addRoundButton.tap()
            
        }
        
        app.swipeLeft()
        app.swipeLeft()
        
    }
    
    @MainActor
    func testMagnifier() throws {
        
        let app = XCUIApplication()
        app.activate()
        
        let names = ["Jimmy", "Timmy"]
        
        app/*@START_MENU_TOKEN@*/.buttons["Create Game"]/*[[".otherElements.buttons[\"Create Game\"]",".buttons[\"Create Game\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add players"]/*[[".otherElements.buttons[\"Add players\"]",".buttons[\"Add players\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let addButton = app/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".otherElements.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        
        for name in names {
            app/*@START_MENU_TOKEN@*/.textFields["Name"]/*[[".otherElements",".textFields[\"Olli\"]",".textFields[\"Name\"]",".textFields"],[[[-1,2],[-1,1],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText(name)
            addButton.tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".otherElements[\"Done\"].buttons",".otherElements.buttons[\"Done\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".otherElements.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let newRoundButton = app/*@START_MENU_TOKEN@*/.buttons["Add new round"]/*[[".otherElements.buttons[\"Add new round\"]",".buttons[\"Add new round\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        newRoundButton.tap()
        
        let elementsQuery = app.textFields.matching(identifier: "0").allElementsBoundByIndex
        
        for field in elementsQuery {
            field.tap()
            field.typeText("0")
        }
        
        let addRoundButton = app.buttons["Add"].firstMatch
        addRoundButton.tap()
                
        app.cells/*@START_MENU_TOKEN@*/.firstMatch/*[[".containing(.other, identifier: nil).firstMatch",".firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        
        app/*@START_MENU_TOKEN@*/.buttons["plus.magnifyingglass"]/*[[".otherElements[\"plus.magnifyingglass\"].buttons",".otherElements",".buttons[\"Zoom In\"]",".buttons[\"plus.magnifyingglass\"]"],[[[-1,3],[-1,2],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons["minus.magnifyingglass"].firstMatch.tap()
        
        app.buttons["Finish"].firstMatch.tap()
    }

    @MainActor
    func testSevenPlayerSingleRound() throws {

        let app = XCUIApplication()
        app.activate()

        let players = ["Jerry", "Jimmy", "Tony", "Dimitri", "Timmy", "Rob", "Kate"]
        let scores = ["10", "4", "12", "17", "33", "1", "12"]

        app/*@START_MENU_TOKEN@*/.buttons["Create Game"]/*[[".otherElements.buttons[\"Create Game\"]",".buttons[\"Create Game\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Add players"]/*[[".otherElements.buttons[\"Add players\"]",".buttons[\"Add players\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        let addButton = app/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".otherElements.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch

        for player in players {
            app/*@START_MENU_TOKEN@*/.textFields["Name"]/*[[".otherElements",".textFields[\"Olli\"]",".textFields[\"Name\"]",".textFields"],[[[-1,2],[-1,1],[-1,3],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.typeText(player)
            addButton.tap()
        }

        app.buttons["Done"].firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".otherElements.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        let rounds = 2
        
        for _ in 0..<rounds {
            app/*@START_MENU_TOKEN@*/.buttons["Add new round"]/*[[".otherElements.buttons[\"Add new round\"]",".buttons[\"Add new round\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
            let textFields = app.textFields.matching(identifier: "0").allElementsBoundByIndex
            for (index, score) in scores.enumerated() {
                textFields[index].tap()
                textFields[index].typeText(score)
            }
            app.buttons["Add"].firstMatch.tap()
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
