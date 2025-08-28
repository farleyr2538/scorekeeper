//
//  CreateGameView.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import SwiftUI
import SwiftData

struct CreateGameView: View {
    
    @EnvironmentObject private var viewModel : ViewModel
    @Environment(\.modelContext) var context
            
    @Bindable var game : Game = Game(players: [], halving: true, lowestWins: true)
    
    @State var newPlayerSheetShowing : Bool = false
    
    @State var isGameError : gameError?
    @State var errorText : String = ""
    @State var showAlert = false
    
    @State var gameStarted = false
        
    var body: some View {
        
        VStack { // enclosing VStack
            
            VStack {
                
                // players
                PlayersView(game: game, newPlayerSheetShowing: $newPlayerSheetShowing)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                
                // game settings
                GameSettings(game: game)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                    .frame(width: 300)
                
            }
            .background(Color.brown.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(50)
            .navigationTitle("Create Game")
            
            Spacer()
            
            Button {
                
                // verify game is valid
                do {
                    try viewModel.verifyGame(game: game)
                } catch let error as gameError {
                    switch error {
                    case .noPlayers:
                        errorText = "Please add players before starting"
                        showAlert = true
                    case .tooManyPlayers:
                        errorText = "There is a maximum of seven players"
                        showAlert = true
                    }
                } catch {
                    errorText = "Unexpected error"
                    showAlert = true
                }
                
                // if so, add player names to player history
                game.players.forEach { player in
                    if !viewModel.allPlayers.contains(where: { $0 == player.name }) {
                        viewModel.addPlayerName(player.name)
                    }
                }
                
                // add the game to persistent memory
                context.insert(game)
                
                
                // try to save
                do {
                    try context.save()
                    print("context saved at game creation")
                    print("number of players in game: \(game.players.count)")
                } catch {
                    print("unable to save game")
                }
                 
                
                // start game
                gameStarted = true
                
                
            } label: {
                FullWidthButton(text: "Start")
                    .padding(.horizontal)
            }
            
            
            .sheet(isPresented: $newPlayerSheetShowing) {
                AddPlayerSheet(
                    game: game,
                    newPlayerSheetShowing: $newPlayerSheetShowing
                )
                .presentationDetents([.medium, .large])
            }
            .alert("Error creating game", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(errorText)
            }
        }
        .navigationDestination(isPresented: $gameStarted) {
            GameView(game: game)
        }
    }
}

#Preview {
    CreateGameView()
        .environmentObject(ViewModel())
}
