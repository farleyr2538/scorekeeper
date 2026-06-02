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
        
        let lengthOfPlayerNames = viewModel.allPlayers.count
        print("playerNames count: \(lengthOfPlayerNames)")
        
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
                            
                            do {
                                try viewModel.addPlayerToGame(
                                    name: name,
                                    game: game,
                                    useContext: useContext,
                                    startScoreMode: startScoreMode
                                )
                            } catch let error {
                                // handle errors
                                switch error {
                                    case addPlayerError.noName:
                                    errorMessage = "Please enter a name"
                                    isError = true
                                case addPlayerError.existingName:
                                    errorMessage = "Name must be different from existing players"
                                    isError = true
                                case addPlayerError.tooManyPlayers:
                                    errorMessage = "Cannot add more than \(maxPlayers) players"
                                    isError = true
                                default:
                                    errorMessage = "Unknown error"
                                    isError = true
                                }
                            }
                            
                            // reset name variable
                            name = ""
                            
                            // save context
                            try? context.save()
                            print("game saved after player added to game")
                            
                            if useContext == .midGame {
                                newPlayerSheetShowing = false
                            }
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
