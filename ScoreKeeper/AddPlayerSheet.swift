//
//  AddPlayer.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct AddPlayerSheet: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @State var newPlayer = Player(
        name: "",
        scores: intArray(values: []),
        runningScores: intArray(values: [])
    )
    
    @Bindable var game : Game
    
    @Binding var newPlayerSheetShowing : Bool
    
    @Environment(\.dismiss) var dismiss
    
    // error
    @State var isError : Bool = false
    @State var errorMessage : String = ""
    
    @FocusState private var textFieldFocused : Bool
    
    var context : Context = .preGame
    
    enum Context {
        case preGame
        case midGame
    }
    
    var body: some View {
        
        NavigationStack {
        
            Group {

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
                        
                        
                        if context == .midGame {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Adding a player mid-game will give them the average score of all players")
                            }
                            .foregroundStyle(.gray)
                            .padding(.vertical, 10)
                        }
                        
                        
                        HStack {
                            TextField("Name", text: $newPlayer.name)
                                .focused($textFieldFocused)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled(true)
                                .frame(maxWidth: 200)
                                .onAppear {
                                    textFieldFocused = true
                                }
                            
                            Button("Add") {
                                
                                if newPlayer.name.isEmpty {
                                    errorMessage = "Please enter a name"
                                    isError = true
                                }
                                
                                game.players.forEach { player in
                                    if player.name == newPlayer.name {
                                        errorMessage = "Player already exists"
                                        isError = true
                                    }
                                }
                                
                                if context == .midGame {
                                    
                                    let avgScore = viewModel.getAverageScore(game: game)
                                    
                                    if avgScore != 0 {
                                        viewModel.addScore(
                                            player: newPlayer,
                                            score: avgScore,
                                            halving: false
                                        )
                                    }
                                    
                                    newPlayerSheetShowing = false
                                }
                                game.players.append(newPlayer)
                                newPlayer = Player(
                                    name: "",
                                    scores: intArray(values: []),
                                    runningScores: intArray(values: [])
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // previous players VStack
                    if (!viewModel.allPlayers.isEmpty) {
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
                                                let newPlayer = Player(
                                                    name: player,
                                                    scores: intArray(values: []),
                                                    runningScores: intArray(values: [])
                                                )
                                                game.players.append(newPlayer)
                                                if context == .midGame {
                                                    newPlayerSheetShowing = false
                                                }
                                                
                                            }
                                        
                                    }
                                }
                                .padding(.leading)
                                
                            }
                        }
                        .padding(.vertical)
                        
                    }
                    
                    Group {
                        if context == .preGame {
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
                    if context == .preGame {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                newPlayerSheetShowing = false
                            } label: {
                                Text("Done")
                                    .bold()
                            }
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
}

#Preview {
        
    AddPlayerSheet(
        game: Game(
            players: [],
            halving: true
        ),
        newPlayerSheetShowing: .constant(true),
        context: .preGame
    )
    .environmentObject(ViewModel())
}
