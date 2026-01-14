//
//  NewPlayerScoreChooser.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 02/12/2025.
//

import SwiftUI

struct NewPlayerScoreChooser: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @Bindable var game : Game
    @Binding var startScoreMode : StartScoreMode
    
    @State var avgScoreForDisplay : Int = 0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("New Player's Score:")
                    .font(.title3)
                HStack {
                    if startScoreMode == .averageScore {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.blue)
                            .opacity(1.0)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.gray)
                            .opacity(0.4)
                    }
                    Text("Average Score")
                    Text("(" + String(avgScoreForDisplay) + ")")
                        .foregroundStyle(.gray)
                }
                .onTapGesture {
                    startScoreMode = .averageScore
                }
                .onAppear {
                    avgScoreForDisplay = viewModel.getAverageScore(game: game)
                }
                HStack {
                    if startScoreMode == .startAtZero {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.blue)
                            .opacity(1)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.gray)
                            .opacity(0.4)
                    }
                    Text("Start at 0")
                }
                .onTapGesture {
                    startScoreMode = .startAtZero
                }
                
            }
            .padding(.vertical, 20)
            Spacer()
        }
    }
}

#Preview {
    NewPlayerScoreChooser(
        game:
            Game(players: [
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
            ),
        startScoreMode: .constant(.averageScore)
        
    )
    .environmentObject(ViewModel())
}
