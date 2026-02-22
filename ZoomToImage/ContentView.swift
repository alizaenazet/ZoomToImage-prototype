//
//  ContentView.swift
//  ZoomToImage
//
//  Created by Ali zaenal on 07/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isMagnifierEnabled = false
    @State private var showClueTrigger: (() -> Void)?
    
    // Example hotspots - adjust these normalized coordinates to match your image
    private let hotspots: [ImageHotspot] = [
        ImageHotspot(
            id: "part1",
            normalizedX: 0.3,   // 30% from left
            normalizedY: 0.7,   // 70% from bottom
            normalizedRadius: 0.06  // 6% of image width
        ),
        ImageHotspot(
            id: "part2",
            normalizedX: 0.7,   // 70% from left
            normalizedY: 0.4,   // 40% from bottom
            normalizedRadius: 0.08  // 8% of image width
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // SpriteKit view for image display (9:16 ratio area)
            SpriteKitView(
                isMagnifierEnabled: $isMagnifierEnabled,
                hotspots: hotspots,
                onShowClue: { trigger in
                    print("[ContentView] onShowClue callback received, setting trigger")
                    showClueTrigger = trigger
                }
            )
            .ignoresSafeArea()
            
            // Bottom menu bar
            MenuBar(
                isMagnifierEnabled: $isMagnifierEnabled,
                onCluePressed: {
                    print("[ContentView] Clue button pressed, trigger exists: \(showClueTrigger != nil)")
                    showClueTrigger?()
                }
            )
        }
        .background(.black)
    }
}

struct MenuBar: View {
    @Binding var isMagnifierEnabled: Bool
    var onCluePressed: () -> Void
    
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
            
            Spacer()
            
            // Clue button
            Button {
                onCluePressed()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "lightbulb.circle")
                        .font(.system(size: 28))
                    
                    Text("Clue")
                        .font(.caption)
                }
                .foregroundStyle(.yellow)
            }
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
