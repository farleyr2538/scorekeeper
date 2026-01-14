//
//  HalvedScore.swift
//  Yanev
//
//  Created by Robert Farley on 27/06/2025.
//

import SwiftUI

struct HalvedScore: View {
    
    let previousScore : Int
    let halvedScore : Int
    
    var body: some View {
        HStack {
            Text("\(previousScore)")
                .padding(.bottom, 1)
                .foregroundStyle(Color.gray)
                .strikethrough(color: Color.gray)
            Text("\(halvedScore)")
                .padding(.bottom, 1)
                .foregroundStyle(Color.green)
        }
    }
}

#Preview {
    HalvedScore(previousScore: 50, halvedScore: 25)
}
