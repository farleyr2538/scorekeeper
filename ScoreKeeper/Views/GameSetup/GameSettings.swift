//
//  GameSettings.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 27/07/2025.
//

import SwiftUI

struct GameSettings: View {
    
    @Bindable var game : Game
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Settings")
                .font(.title3)
                .bold()
            VStack(spacing: 10) {
                Toggle("Halving", isOn: $game.halving)
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("If a player hits a multiple of 50, half their score")
                        .font(.caption)
                }
                .foregroundStyle(Color.gray)
            }
            
            Toggle("Lowest score wins", isOn: $game.lowestWins)
            
        }
    }
}

#Preview {
    GameSettings(game: Game(players: [], halving: true))
}
