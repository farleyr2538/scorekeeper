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
        return allPlayers.filter { playerTuple in
            playerTuple.0.lowercased().starts(with: name.lowercased())
            &&
            !game.players.contains(where: { $0.name == playerTuple.0 })
        }
    }
 
    var body: some View {
        
        if !allPlayers.isEmpty {
            
            // previous players VStack
            VStack(alignment: .leading) {
                
                Text("Previous players")
                    .font(.title3)
                    .padding(.leading)
                        
                if filteredPlayers.isEmpty {

                    Text("No previous players starting with \"\(name)\" found")
                        .foregroundStyle(Color.gray)
                        .padding()

                } else {
                    
                    ScrollView(.horizontal) {
                        HStack(alignment: .center) {
                            // for each player, show a selectable name that the user can press to add to the game
                            ForEach(filteredPlayers, id: \.0) { playerName, count in
                                NameTag(name: playerName)
                                    .onTapGesture {
                                
                                        let existingPlayers = game.players.map(\.name)
                                        
                                        print("existingPlayers array: \(existingPlayers)")
                                
                                        if existingPlayers.contains(playerName) {
                                                errorMessage = "Player already exists"
                                                isError = true
                                        } else {
                                            if useContext == .preGame { // create a new player with the corresponding name, and add it to the game
                                                let newPlayer = Player(
                                                    name: playerName,
                                                    scores: [],
                                                    runningScores: []
                                                )
                                        
                                                game.players.append(newPlayer)
                                                name = ""
                                        
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
