//
//  ScoreNumber.swift
//  Yanev
//
//  Created by Robert Farley on 27/06/2025.
//

import SwiftUI

struct ScoreNumber: View {
    
    let score : Double
    let context : Context
    let roundIndex : Int
    
    enum Context {
        case runningScores
        case scores
    }
    
    var shouldHighlightZeros : Bool {
        if context == .scores && score == 0 && roundIndex != 0 {
            return true
        } else {
            return false
        }
    }
    
    var formattedScore: String {
        // If the score is a whole number, display without decimals
        if score.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(score))
        } else {
            return String(score)
        }
    }
    
    var body: some View {
            
        Text(formattedScore)
        //.font(.system(size: 20, weight: .regular))
            .padding(.bottom, 1)
            .foregroundStyle(shouldHighlightZeros ? Color.orange : Color.primary)
        
    }
}

#Preview {
    ScoreNumber(score: 16, context: .scores, roundIndex: 3)
}
