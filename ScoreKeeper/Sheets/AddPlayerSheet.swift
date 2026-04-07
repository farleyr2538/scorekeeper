//
//  AddPlayer.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import Foundation
import SwiftUI
import SwiftData

enum StartScoreMode {
    case startAtZero
    case averageScore
}

enum Context {
    case preGame
    case midGame
}

struct AddPlayerSheet: View {
    
    @EnvironmentObject var viewModel : ViewModel
    @Environment(\.modelContext) var context
        
    @State var name : String = ""
    @Bindable var game : Game
    @Binding var newPlayerSheetShowing : Bool
    
    // error handling
    @State var isError : Bool = false
    @State var errorMessage : String = ""
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var textFieldFocused : Bool
    
    // context
    var useContext : Context = .preGame
    
    @State var startScoreMode : StartScoreMode = .averageScore
    
    var allPlayers : [(String, Int)] {
        
        // transform playerNames into either a dictionary or an array of tuples
        let playersCountDict = viewModel.allPlayers.reduce(into: [:]) { dict, value in
            dict[value, default: 0] += 1
        } // { ["Rob", 4], ["Jamie", 2], ... }
        print("playersCountDict:\n\(playersCountDict)")
        
        let sortedArray = playersCountDict.sorted(by: {
            if $0.value != $1.value {
                return $0.value > $1.value
            } else {
                return $0.key < $1.key
            }
        })
        print("sortedArray:\n\(sortedArray)")
        
        return sortedArray
    }
    
    var body: some View {
        
        NavigationStack {
        
            VStack {
                
                // custom players VStack
                VStack {
                    
                    HStack {
                        Text("Add Players")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        TextField("Name", text: $name)
                            .focused($textFieldFocused)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled(true)
                            .frame(maxWidth: 300)
                            .onAppear {
                                textFieldFocused = true
                            }
                        
                        Button("Add") {
                            
                            // if there is no name, reject
                            if name.isEmpty {
                                errorMessage = "Please enter a name"
                                isError = true
                            }
                            
                            // if there is already a player with that name, reject - this is not working when it should
                            let existingPlayersNames = game.players.map(\.name)
                            
                            existingPlayersNames.forEach { playerName in
                                if playerName == name {
                                    errorMessage = "Player already exists"
                                    isError = true
                                }
                            }
                            
                            // only proceed if there is not an error
                            if !isError {
                                
                                let newPlayer = Player(
                                    name: name,
                                    scores: [],
                                    runningScores: []
                                )
                                
                                if useContext == .midGame {
                                    
                                    let numberOfRounds = game.roundsPlayed
                                    print("numberOfRounds: " + String(numberOfRounds))
                                    
                                    // add zeros for all rounds played so far (except the current one)
                                    if numberOfRounds > 0 {
                                        for _ in 0 ..< (numberOfRounds - 1) {
                                            viewModel.addScore(
                                                player: newPlayer,
                                                score: 0,
                                                halving: false
                                            )
                                        }
                                    }
                                    
                                    let firstScore : Double
                                    
                                    if startScoreMode == .averageScore {
                                        firstScore = viewModel.getAverageScore(game: game)
                                    } else {
                                        firstScore = 0
                                    }
                                    
                                    viewModel.addScore(
                                        player: newPlayer,
                                        score: firstScore,
                                        halving: false
                                    )
                                    
                                    newPlayerSheetShowing = false
                                }
                                
                                // add player to game
                                game.players.append(newPlayer)
                                
                                // save context
                                try? context.save()
                            }
                            
                            // reset name variable
                            name = ""
                            
                        }
                        
                    }
                    .padding(.vertical)
                    
                    // option to select new player's score
                    if useContext == .midGame {
                        NewPlayerScoreChooser(game: game, startScoreMode: $startScoreMode)
                    }
                    
                    
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                .padding(.top, 10)
                
                PreviousPlayers(
                    allPlayers: allPlayers,
                    game: game,
                    useContext: useContext,
                    isError: $isError,
                    errorMessage: $errorMessage,
                    name: $name
                )
                
                // when pre-game, display players added while sheet is showing
                Group {
                    if useContext == .preGame {
                        if !game.players.isEmpty {
                            
                            VStack {
                                ForEach(game.players) { player in
                                    HStack {
                                        Text(player.name)
                                        
                                        Button {
                                            game.players.removeAll(where: { $0.id == player.id })
                                        } label: {
                                            Image(systemName: "xmark.circle")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                .padding(.bottom, 1)
                            }
                            .padding(.vertical, 20)
                            
                        } else {
                            HStack {
                                Text("No players added to game")
                                    .foregroundStyle(.gray)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 1)
                
                Spacer()
                
            } // end of ScrollView
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                if useContext == .preGame {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            newPlayerSheetShowing = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .alert("Error", isPresented: $isError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }

        }
                
    }
}

#Preview {
        
    AddPlayerSheet(
        game: Game(
            players: [],
            halving: true
        ),
        newPlayerSheetShowing: .constant(true),
        useContext: .midGame
    )
    .environmentObject(ViewModel())
}
