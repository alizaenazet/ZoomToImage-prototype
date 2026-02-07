//
//  ContentView.swift
//  ZoomToImage
//
//  Created by Ali zaenal on 07/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isMagnifierEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            // SpriteKit view for image display (9:16 ratio area)
            SpriteKitView(isMagnifierEnabled: $isMagnifierEnabled)
                .ignoresSafeArea()
            
            // Bottom menu bar
            MenuBar(isMagnifierEnabled: $isMagnifierEnabled)
        }
        .background(.black)
    }
}

struct MenuBar: View {
    @Binding var isMagnifierEnabled: Bool
    
    var body: some View {
        HStack(spacing: 32) {
            // Magnifier toggle button
            Button {
                isMagnifierEnabled.toggle()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isMagnifierEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                        .font(.system(size: 28))
                    
                    Text("Magnifier")
                        .font(.caption)
                }
                .foregroundStyle(isMagnifierEnabled ? .blue : .white)
            }
            
            // Placeholder for additional menu items
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ContentView()
}
