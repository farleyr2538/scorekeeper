//
//  PlayersView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 14/07/2025.
//

import SwiftUI
import SwiftData

struct PlayersView: View {
    
    @Bindable var game : Game
    
    @Binding var newPlayerSheetShowing : Bool
    
    var body: some View {
    
        VStack {
            Text("Players")
                .font(.title3)
                .bold()
                .padding(.bottom, 20)
            
            if !game.players.isEmpty {
                
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
                    .padding(.bottom, 1)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            } else {
                HStack {
                    Text("No players added to game")
                        .foregroundStyle(.gray)
                        .padding(.top, 5)
                }
            }
            
            Button("Add players") {
                newPlayerSheetShowing = true
            }
            .padding(.top, 15)
        }        
    }
}


#Preview {
    
    PlayersView(
        game: Game(
            players: [],
            halving: false,
        ),
        newPlayerSheetShowing: .constant(false)
    )
}
