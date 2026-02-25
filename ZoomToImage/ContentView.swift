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
    @State private var resetHotspotsTrigger: (() -> Void)?
    
    /// Shows the welcome page only once at the start
    @State private var showWelcome = true
    
    /// Controls which scene is shown: true = investigation, false = conversation
    @State private var isInvestigating = true
    
    /// Unique key to force SpriteKitView recreation on scene return
    @State private var investigationKey = UUID()
    
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
        ZStack {
            if showWelcome {
                // Welcome page - shown once at the start
                WelcomeView(onStartGame: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcome = false
                    }
                })
                .transition(.opacity)
            } else if isInvestigating {
                // Investigation scene
                VStack(spacing: 0) {
                    SpriteKitView(
                        isMagnifierEnabled: $isMagnifierEnabled,
                        hotspots: hotspots,
                        onShowClue: { trigger in
                            showClueTrigger = trigger
                        },
                        onAllHotspotsFound: {
                            print("[ContentView] All hotspots found! Switching to conversation.")
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isInvestigating = false
                            }
                        },
                        onResetHotspots: { trigger in
                            resetHotspotsTrigger = trigger
                        }
                    )
                    .id(investigationKey)
                    .ignoresSafeArea()
                    
                    // Bottom menu bar
                    MenuBar(
                        isMagnifierEnabled: $isMagnifierEnabled,
                        onCluePressed: {
                            showClueTrigger?()
                        }
                    )
                }
                .transition(.opacity)
            } else {
                // Conversation scene
                ConversationView(onConversationEnd: {
                    print("[ContentView] Conversation ended. Returning to investigation.")
                    // Reset for next round
                    investigationKey = UUID()
                    showClueTrigger = nil
                    resetHotspotsTrigger = nil
                    isMagnifierEnabled = false
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isInvestigating = true
                    }
                })
                .transition(.opacity)
            }
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
