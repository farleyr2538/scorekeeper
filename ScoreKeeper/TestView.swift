//
//  TestView.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 06/04/2026.
//

import SwiftUI

struct TestView: View {
    
    @State var testString : String = "0"
    
    var body: some View {
        TextField("Test", text: $testString)
            .keyboardType(.decimalPad)
    }
}

#Preview {
    TestView()
}
