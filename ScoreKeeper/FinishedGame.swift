//
//  FinishedGame.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 03/07/2025.
//

import SwiftUI
import SwiftData

struct FinishedGame: View {
    
    @Bindable var game : Game
    
    var topPadding : CGFloat = 15
    
    @State var selectedTab : Tab = Tab.stats
    
    enum Tab {
        case stats
        case scoreboard
    }
    
    var body: some View {
        
        VStack {
            TabView(selection: $selectedTab) {
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Leaderboard")
                            .font(.title2)
                            .padding(.top, topPadding)
                        Leaderboard(game: game)
                        
                        Text("Game Progress")
                            .font(.title2)
                            .padding(.top, topPadding)
                        ScoreChart(game: game)
                        
                        Text("Player averages")
                            .font(.title2)
                            .padding(.top, topPadding)
                        AveragesView(game: game)

                    }
                    .frame(maxWidth: 400)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 60)
                    .navigationTitle("Game Stats")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tag(Tab.stats)
                
                ScoresGrid(
                    currentGame: game,
                    roundToEdit: .constant(0),
                    editRoundSheetShowing: .constant(false)
                )
                .navigationTitle("Scoreboard")
                .tag(Tab.scoreboard)
                
                
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            
            NavigationLink {
                ContentView()
                    .navigationBarBackButtonHidden()
            } label: {
                HStack {
                    Spacer()
                    FullWidthButton(text: "Home")
                    Spacer()
                }
            }            
        }
    }
}

#Preview {
        
    NavigationView {
        FinishedGame(
            game: Game(players: [
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
                halving: true
            )
        )
    }
}
