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
    @State var startButtonPressed : Bool = false
    
    @State var gameID : UUID?
    @State var gameStarted = false
    @State var gameName = ""
        
    var body: some View {
        
        VStack { // enclosing VStack
            
            VStack(spacing: 40) {
                
                // players
                PlayersView(game: game, newPlayerSheetShowing: $newPlayerSheetShowing)
                
                // game settings
                GameSettings(game: game)
                
                // game name
                GameNameView(gameName: $gameName)
                
            }
            .frame(width: 250)
            .padding(30)
            .background(Color.brown.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Spacer()
            
            Button {
                
                // abstract this out to ViewModel
                
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
                
                // if game is valid, add player names to player history
                game.players.forEach { player in
                    viewModel.addPlayerName(player.name)
                }
                
                // similarly, add game name to gameNames
                gameName = gameName.trimmingCharacters(in: .whitespaces)
                if gameName != "" && !viewModel.gameNames.contains(where: { $0 == gameName }) {
                    viewModel.gameNames.append(gameName)
                }
                
                // increment roundsPlayed accordingly
                game.roundsPlayed += 1
                
                game.name = gameName
                gameID = game.id
                
                // add the game to persistent memory
                context.insert(game)
                
                // try to save
                do {
                    try context.save()
                    
                    // start game
                    if !showAlert {
                        gameStarted = true
                    }
                    
                } catch {
                    print("unable to save game")
                }
            } label: {
                FullWidthButton(text: "Start")
                    .padding(.horizontal)
            }
            .scaleEffect(startButtonPressed ? 0.9 : 1.0)
            .animation(.spring(), value: startButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { _ in startButtonPressed = true }
                    .onEnded { _ in startButtonPressed = false }
            )
            
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
            if let gameID = gameID {
                GameView(id: gameID)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateGameView()
            .environmentObject(ViewModel())
    }
}
