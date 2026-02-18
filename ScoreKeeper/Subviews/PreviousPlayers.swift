//
//  PreviousPlayers.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 18/02/2026.
//

import SwiftUI

struct PreviousPlayers: View {
    
    var allPlayers : [(String, Int)]
    
    @Bindable var game : Game
    
    var useContext : Context
    
    // error handling
    @Binding var isError : Bool
    @Binding var errorMessage : String
    
    @Binding var name : String
    
    var filteredPlayers : [(String, Int)] {
        return allPlayers.filter { $0.0.lowercased().starts(with: name.lowercased()) }
    }
 
    var body: some View {
        
        // previous players VStack
        if !allPlayers.isEmpty {
            
            VStack(alignment: .leading) {
                
                Text("Previous players")
                    .font(.title3)
                    .padding(.leading)
                
                ScrollView(.horizontal) {
                    
                    HStack {
                        // for each player, show a selectable name that the user can press to add to the game
                        ForEach(filteredPlayers, id: \.0) { playerName, count in
                            NameTag(name: playerName)
                                .onTapGesture {
                                    
                                    let existingPlayers = game.players.map(\.name)
                                    print("existingPlayers array: \(existingPlayers)")
                                    
                                    if existingPlayers.contains(playerName) {
                                        isError = true
                                        errorMessage = "Player already exists"
                                    } else {
                                        if useContext == .preGame { // create a new player with the corresponding name, and add it to the game
                                            let newPlayer = Player(
                                                name: playerName,
                                                scores: [],
                                                runningScores: []
                                            )
                                            
                                            game.players.append(newPlayer)
                                            
                                        } else if useContext == .midGame { // just insert name into textfield so user can choose score calculation method
                                            
                                            name = playerName
                                            // newPlayerSheetShowing = false
                                        }
                                    }
                                }
                            
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .scrollIndicators(.hidden)
            }
            .padding(.vertical)
            
            
        }
    }
}

#Preview {
    PreviousPlayers(
        allPlayers: [
            ("Jerry", 4),
            ("Jimmy", 2)
        ],
        game: Game.sampleGames.first!,
        useContext: Context.preGame,
        isError: .constant(false),
        errorMessage: .constant(""),
        name: .constant("")
    )
}
