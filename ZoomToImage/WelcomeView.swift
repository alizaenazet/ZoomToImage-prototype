//
//  WelcomeView.swift
//  ZoomToImage
//
//  Created by AI Assistant on 07/02/26.
//

import SwiftUI

/// Welcome page shown once at the start of the game.
struct WelcomeView: View {
    var onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("Image Detective")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: {
                onStartGame()
            }) {
                Text("Start Game")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            
            Spacer()
                .frame(height: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    WelcomeView(onStartGame: {})
}
