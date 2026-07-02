//
//  PlayersView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 14/07/2025.
//

import SwiftUI
import SwiftData
import WrappingHStack

struct PlayersView: View {
    
    @Bindable var game : Game
    
    @Binding var newPlayerSheetShowing : Bool
    
    enum PlayersViewPreference {
        case all
        case justPlayerTags
    }
    var preference : PlayersViewPreference
    
    var body: some View {
    
        VStack {
            
            if preference == .all {
                Text("Players")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 20)
            }
            
            if !game.players.isEmpty {
                
                WrappingHStack(game.players, id: \.self, alignment: .leading) { player in
                    HStack(spacing: 4) {
                        Text(player.name)
                            .font(.system(size: 14))
                        
                        Button {
                            game.players.removeAll(where: { $0.id == player.id })
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(.red)
                        }
                        
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .fixedSize()
                    .background(preference == .all ? Color.darkAndLight : Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.vertical, 5)
                }
                
            } else {
                HStack {
                    Text("No players added to game")
                        .foregroundStyle(.gray)
                        .padding(.top, 5)
                }
            }
            
            if preference == .all {
                Button("Add players") {
                    newPlayerSheetShowing = true
                }
                .padding(.top, 15)
            }
        }
    }
}


#Preview {
    VStack {
        PlayersView(
            game: Game(
                players: Player.sampleEightPlayers,
                halving: false,
            ),
            newPlayerSheetShowing: .constant(false),
            preference: .all
        )
    }
    .frame(width: 250)
    .background(Color.gray.opacity(0.1))
}
