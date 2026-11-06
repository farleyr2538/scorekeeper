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
            
    @Bindable var game : Game = Game(
        players: [],
        halving: true,
        lowestWins: true
    )
    
    // the user's default settings for new games (see SettingsView)
    @AppStorage(SettingsKey.defaultHalving) private var defaultHalving : Bool = true
    @AppStorage(SettingsKey.defaultLowestWins) private var defaultLowestWins : Bool = true
    @State private var defaultsApplied = false
    
    @State var newPlayerSheetShowing : Bool = false
    
    @State var isGameError : gameError?
    @State var errorText : String = ""
    @State var showAlert = false
    @State var startButtonPressed : Bool = false
    
    @State var gameID : UUID?
    @State var gameStarted = false
    @State var gameName = ""
            
    var body: some View {
        
        VStack {
            
            ScrollViewReader { scrollProxy in
                
                ScrollView {
                    
                    VStack { // enclosing VStack
                        
                        VStack(spacing: 40) {
                            
                            // players
                            PlayersView(
                                game: game,
                                newPlayerSheetShowing: $newPlayerSheetShowing,
                                preference: .all
                            )
                            
                            // game settings
                            GameSettings(game: game)
                            
                            // game name
                            GameNameView(
                                gameName: $gameName,
                                proxy: scrollProxy
                            )
                            
                        }
                        .frame(maxWidth: 300)
                        .padding(25)
                        .background(Color.brown.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal, 40)
                        
                        Spacer()
                                                
                        .sheet(isPresented: $newPlayerSheetShowing) {
                            NewPlayerSheet(
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
                    //.padding(.bottom, 200)
                }
            }
            
            Button {
                
                do {
                    try viewModel.prepareGameForCreation(game: game, gameName: gameName)
                    
                    gameID = game.id
                    
                    // add the game to persistent memory
                    context.insert(game)
                    
                    try context.save()
                    
                    // start game
                    if !showAlert {
                        gameStarted = true
                    }
                    
                } catch let error as gameError {
                    switch error {
                    case .noPlayers:
                        errorText = "You need to add at least 2 players"
                        showAlert = true
                    case .tooManyPlayers:
                        errorText = "Maximum players: \(maxPlayers)"
                        showAlert = true
                    }
                } catch {
                    errorText = "An unexpected error occured"
                    showAlert = true
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
            
        }
        
        // apply the defaults once, when the screen is first shown, so they're
        // current and don't overwrite any changes made on this screen
        .onAppear {
            guard !defaultsApplied else { return }
            game.halving = defaultHalving
            game.lowestWins = defaultLowestWins
            defaultsApplied = true
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
