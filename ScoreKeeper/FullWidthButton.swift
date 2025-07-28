//
//  FullWidthButton.swift
//  Yanev
//
//  Created by Robert Farley on 26/06/2025.
//

import SwiftUI

struct FullWidthButton: View {
    
    var text : String
    
    var body: some View {
        ZStack {
            Capsule()
                .foregroundStyle(.blue)
            Text(text)
                .foregroundStyle(.white)
                .font(.title3)
        }
        .frame(maxWidth: 400, maxHeight: 75)
        .frame(minHeight: 75)
    }
}

#Preview {
    FullWidthButton(text: "Hello, World!")
}
