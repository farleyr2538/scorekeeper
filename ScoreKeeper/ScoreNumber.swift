//
//  ScoreNumber.swift
//  Yanev
//
//  Created by Robert Farley on 27/06/2025.
//

import SwiftUI

struct ScoreNumber: View {
    
    let score : Int
    let context : Context
    
    enum Context {
        case runningScores
        case scores
    }
    
    var shouldHighlightZeros : Bool {
        if context == .scores && score == 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
            
        Text("\(score)")
        //.font(.system(size: 20, weight: .regular))
            .padding(.bottom, 1)
            .foregroundStyle(shouldHighlightZeros ? Color.orange : Color.primary)
        
    }
}

#Preview {
    ScoreNumber(score: 16, context: .scores)
}
