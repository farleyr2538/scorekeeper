//
//  NameTag.swift
//  Yanev
//
//  Created by Robert Farley on 24/06/2025.
//

import SwiftUI

struct NameTag: View {
    
    var name : String
    
    var body: some View {
        Text(name)
            .padding(10)
            .containerShape(.capsule)
            .background(Color.yellow)
            .cornerRadius(15)
            .foregroundStyle(Color.black)
    }
}

#Preview {
    NameTag(name: "Rob")
}
