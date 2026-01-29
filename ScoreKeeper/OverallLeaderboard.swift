//
//  OverallLeaderboard.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 28/01/2026.
//

import SwiftUI
import SwiftData
import Charts

struct OverallLeaderboard: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @Query var games : [Game]
    
    @State var gameName : String = "All Games"
    
    var body: some View {
        
        let data = games.getWinners(gameName: gameName)
        let gameNames = viewModel.gameNames
        
        VStack {
             
            Spacer()
            
            if data.isEmpty {
                Text("No data")
                    .foregroundStyle(.gray)
            } else {
                
                    
                    Chart(data, id: \.name) {
                        BarMark(
                            x: .value("Name", $0.name),
                            y: .value("Wins", $0.wins))
                    }
                    .frame(width: 300, height: 300)
                
            }
            
            Spacer()
            
            Picker("Game", selection: $gameName) {
                Text("All Games").tag("All Games")
                ForEach(gameNames.indices, id: \.self) { index in
                    Text(gameNames[index]).tag(gameNames[index])
                }
                
            }
            .pickerStyle(.menu)
        }
        .navigationTitle("Game History Statistics")
        
    }
    
    /*
    private func getOverallStats(forGameName: String) -> [String : Int] {
        let games = games.filter { $0.name == forGameName }
        var gameWinners : [String] = []
        for game in games {
            let winners = game.winners
            if winners.count == 1 {
                gameWinners.append(winners.first!.name)
            }
        }
        var winDict : [String : Int] = [:]
        for winner in gameWinners {
            if winDict.keys.contains(winner) {
                winDict[winner]! += 1
            } else {
                winDict[winner] = 1
            }
        }
        return winDict
    }
     */
}

extension Array where Element == Game {
    func getWinners(gameName: String) -> [(name: String, wins: Int)] {
        
        var gamesWithCorrectName : [Game] = []
        
        if gameName != "All Games" {
            // get array of winner names in this game
            gamesWithCorrectName = self.filter( {$0.name == gameName} )
        } else {
            gamesWithCorrectName = self
        }
        var winners: [String] = []
        
        for game in gamesWithCorrectName {
            if game.winners.count == 1 && game.players.count > 1 {
                winners.append(game.winners.first!.name)
            }
        }
        
        let uniqueNames = Set(winners)
        var winnersTupleArray : [(name: String, wins: Int)] = []
        
        for name in uniqueNames {
            let wins = winners.filter( {$0 == name} ).count
            winnersTupleArray.append(
                (name: name, wins: wins)
            )
        }
        
        return winnersTupleArray
    }
}

#Preview {
    NavigationStack {
        OverallLeaderboard()
            .environmentObject(ViewModel())
            .modelContainer(for: [Game.self, Player.self], inMemory: true) { result in
                if case .success(let container) = result {
                    Game.sampleGames.forEach { game in
                        container.mainContext.insert(game)
                    }
                    
                }
            }
    }
}
