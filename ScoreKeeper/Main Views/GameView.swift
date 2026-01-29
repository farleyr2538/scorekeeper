//
//  GameView.swift
//  Yanev
//
//  Created by Robert Farley on 23/06/2025.
//

import SwiftUI
import SwiftData

struct GameView: View {
    
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject var viewModel : ViewModel

    @State var newRoundSheetShowing : Bool = false
    @State var newPlayerSheetShowing : Bool = false
    @State var editRoundSheetShowing : Bool = false
    @State var editGameSheetShowing : Bool = false
    
    @State var gameName : String = ""
    @State var lowestWins : Bool = true
    
    @State var roundIndex : Int = 0
        
    @State var endGameAlertShowing : Bool = false
    
    enum Tab {
        case scoresGridTab
        case leaderboardTab
        case chartTab
    }
    
    @State var selectedTab : Tab = .scoresGridTab
    
    @State var isZoomed : Bool = false
    
    // error handling
    @State var isError : Bool = false
    @State var errorMessage : String = ""
    
    var id : UUID
    
    @Query var games : [Game]
    var game : Game? {
        games.first(where: { $0.id == id })
    }
        
    var body: some View {
        
        if let game = game {
            Group {
                TabView(selection: $selectedTab) {
                    
                    ScoresGrid(
                        game: game,
                        roundToEdit: $roundIndex,
                        editRoundSheetShowing: $editRoundSheetShowing
                    )
                    .navigationTitle("Scores")
                    .tag(Tab.scoresGridTab)
                        
                    ScrollView {
                        Leaderboard(game: game)
                            // .frame(width: 350)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    .navigationTitle("Leaderboard")
                    .tag(Tab.leaderboardTab)
                    .font(isZoomed ? .system(size: 40) : .body)
                    .animation(.easeIn, value: isZoomed)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isZoomed.toggle()
                            } label: {
                                Image(systemName: isZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                            }
                        }
                    }
                    
                    VStack {
                        ScoreChart(game: game)
                            .navigationTitle("Progress Chart")
                            .padding()
                        Spacer()
                    }
                    .tag(Tab.chartTab)
                        
                        
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
            }
            
            .onAppear {
                gameName = game.name ?? ""
                lowestWins = game.lowestWins
            }
            
            .toolbar {
                ToolbarItem {
                    Button {
                        editGameSheetShowing = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            
            .alert("Error", isPresented: $isError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            
            Spacer()
            
            VStack { // VStack for buttons
                Button {
                    newRoundSheetShowing = true
                } label: {
                    FullWidthButton(text: "Add new round")
                }
                
                HStack(spacing: 25) {
                    
                    Button {
                        // average in a new player
                        newPlayerSheetShowing = true
                    } label: {
                        Text("Add Player")
                            .padding(10)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    
                    NavigationLink {
                        FinishedGame(game: game)
                    } label: {
                        Text("Finish")
                            .padding(10)
                            .foregroundStyle(Color.blue)
                    }
                    .clipShape(.capsule)
                    .buttonStyle(.bordered)
                    .onTapGesture {
                        do {
                            try context.save()
                            print("context saved with end of game")
                        } catch {
                            print("failed to save context at end of game")
                        }
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: 350)
                
            
            // new round sheet
            .sheet(isPresented: $newRoundSheetShowing) {
                NewRoundSheet(
                    currentGame: game,
                    newRoundSheetShowing: $newRoundSheetShowing
                )
                .presentationDetents([.medium, .large])
            }
            // new player sheet
            .sheet(isPresented: $newPlayerSheetShowing) {
                AddPlayerSheet(
                    game: game,
                    newPlayerSheetShowing: $newPlayerSheetShowing,
                    useContext: .midGame
                )
                .presentationDetents([.large])
            }
            // edit round sheet
            .sheet(isPresented: $editRoundSheetShowing) {
                EditRoundSheet(
                    game: game,
                    editRoundSheetShowing: $editRoundSheetShowing,
                    roundIndex: $roundIndex
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $editGameSheetShowing) {
                VStack(spacing: 20) {
                    HStack {
                        Text("Edit Game")
                            .font(.title.bold())
                        Spacer()
                    }
                    
                    Divider()
                        .padding(.bottom, 10)
                    
                    HStack(spacing: 20) {
                        Text("Game name")
                        TextField("eg. Yaniv", text: $gameName)
                            .presentationDetents([.medium])
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Toggle("Lowest score wins", isOn: $lowestWins)
                    
                    HStack {
                        
                        Spacer()
                        
                        Button {
                            editGameSheetShowing = false
                        } label: {
                            Text("Cancel")
                                .padding(5)
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button {
                            game.name = gameName
                            game.lowestWins = lowestWins
                            
                            if !viewModel.gameNames.contains(gameName) {
                                viewModel.gameNames.append(gameName)
                            }
                            
                            try? context.save()
                            
                            editGameSheetShowing = false
                        } label: {
                            Text("Save")
                                .padding(5)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 50)
                
            }
            
        } else {
            Group {
                VStack(alignment: .center, spacing: 10) {
                    Text("Error: No game found")
                    Text("Game ID received: \(id.uuidString)")
                }
                .foregroundStyle(.gray)
                .frame(width: 350)
            }
        }
    }
}

#Preview {
        
    let previewGame = Game(
        players: [
            Player(
                name: "Rob",
                scores: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0],
                runningScores: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156]
            ),
            Player(
                name: "Flora",
                scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
                runningScores: [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365]
            ),
            Player(
                name: "Vnesh",
                scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19],
                runningScores: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100]
            )
        ],
        name: "Yaniv",
        halving: true,
        roundsPlayed: 17
    )
        
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, configurations: config)
    container.mainContext.insert(previewGame)
    
    return NavigationStack {
        GameView(id: previewGame.id)
            .modelContainer(container)
            .environmentObject(ViewModel())
    }
}
