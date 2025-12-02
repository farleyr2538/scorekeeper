//
//  PlayerScoreRow.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 02/12/2025.
//

import SwiftUI

struct PlayerScoreRow: View {
    
    @Binding var player : Player
    @Binding var scoreBuffer : String
    @Binding var indexOfNegativeNumbers : [Int]
    var index : Int
    
    @State var isNegative : Bool = false
    
    var body: some View {
        HStack {
            Text(player.name)
            Spacer()
            if (isNegative) {
                Text("-")
            }
            TextField("0", text: $scoreBuffer)
                .textFieldStyle(.roundedBorder)
                .frame(width: 75)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                //.focused($focusedField, equals: index)
            if isNegative {
                Button("-/+") {
                    isNegative.toggle()
                    indexOfNegativeNumbers.removeAll(where: { $0 == index })
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("-/+") {
                    isNegative.toggle()
                    indexOfNegativeNumbers.append(index)
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(width: 300)
    }
}

#Preview {
    PlayerScoreRow(
        player: .constant(
            Player(name: "Rob", scores: [0, 5, 10], runningScores: [0, 5, 15])
            ),
        scoreBuffer: .constant("5"),
        indexOfNegativeNumbers: .constant([0, 1, 2]),
        index: 5
    )
}
