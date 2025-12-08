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
    
    var body: some View {
        
        NavigationStack {
        

            ScrollView {
                
                // add custom players VStack
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
                    }
                    .padding(.vertical)
                    
                    // option to select new player's score
                    if useContext == .midGame {
                        NewPlayerScoreChooser(game: game, startScoreMode: $startScoreMode)
                    }
                    
                    Button("Add") {
                        
                        // if there is no name, reject
                        if name.isEmpty {
                            errorMessage = "Please enter a name"
                            isError = true
                        }
                        
                        // if there is already a player with that name, reject
                        game.players.forEach { player in
                            if player.name == name {
                                errorMessage = "Player already exists"
                                isError = true
                            }
                        }
                        
                        let newPlayer = Player(
                            name: name,
                            scores: [],
                            runningScores: []
                        )
                        
                        if useContext == .midGame {
                            
                            let numberOfRounds = game.roundsPlayed
                            print("numberOfRounds: " + String(numberOfRounds))
                            
                            // add zeros for numberOfRounds (so far)
                            for _ in 1 ..< numberOfRounds {
                                viewModel.addScore(
                                    player: newPlayer,
                                    score: 0,
                                    halving: false
                                )
                            }
                            
                            let firstScore : Int
                            
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
                        
                        // reset name variable
                        name = ""
                        
                    }
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // previous players VStack
                if !viewModel.allPlayers.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Previous players")
                            .font(.title3)
                            .padding(.leading)
                        ScrollView(.horizontal) {
                            HStack {
                                // for each player, show a selectable name that the user can press to add to the game
                                ForEach(viewModel.allPlayers, id: \.self) { player in
                                    NameTag(name: player)
                                        .onTapGesture {
                                            
                                            if useContext == .preGame { // create a new player with the corresponding name, and add it to the game
                                                let newPlayer = Player(
                                                    name: player,
                                                    scores: [],
                                                    runningScores: []
                                                )
                                                
                                                game.players.append(newPlayer)
                                                
                                            } else if useContext == .midGame { // just insert name into textfield so user can choose score calculation method
                                                
                                                name = player
                                                // newPlayerSheetShowing = false
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
                .padding(.bottom, 1)
                
                Spacer()
                
            }
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
