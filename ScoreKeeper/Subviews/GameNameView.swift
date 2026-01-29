//
//  GameNameView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 22/12/2025.
//

import SwiftUI

struct GameNameView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var gameName : String
    @FocusState private var isFocussed : Bool
    
    @State var pickerName : String = ""
    var pickerOptions : [String] { viewModel.gameNames }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Game Name")
                .font(.title3.bold())
            
            
            if viewModel.gameNames.isEmpty {
                TextField("Optional (eg. 'Yaniv')", text: $gameName)
                    
                    .padding(10)
                    .autocorrectionDisabled()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.05))
                            .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                    )
                    
                    .focused($isFocussed)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isFocussed = false
                            }
                        }
                    }
            } else {
                // picker
                Picker("Optional (eg. 'Yaniv')", selection: $pickerName) {
                    ForEach(pickerOptions.indices, id: \.self) { index  in
                        Text(pickerOptions[index])
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}

#Preview {
    GameNameView(gameName: .constant(""))
        .environmentObject(ViewModel())
}
