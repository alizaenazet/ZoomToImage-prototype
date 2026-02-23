//
//  ConversationView.swift
//  ZoomToImage
//
//  Created by AI Assistant on 07/02/26.
//

import SwiftUI

/// Criminal Case-style conversation scene between two subjects.
/// Tap to advance: Subject A greeting → Subject B reply → back to investigation.
struct ConversationView: View {
    
    /// Called when the conversation ends and it's time to return to investigation
    var onConversationEnd: () -> Void
    
    // Conversation state: 0 = Subject A speaks, 1 = Subject B replies
    @State private var conversationStep: Int = 0
    
    // Animate text box appearance
    @State private var showTextBox: Bool = false
    
    // Subject definitions
    private let subjectA = Subject(
        name: "Detective Mason",
        avatar: "person.circle.fill",
        color: .blue
    )
    
    private let subjectB = Subject(
        name: "Officer Riley",
        avatar: "person.circle.fill",
        color: .green
    )
    
    // Dialogue lines
    private let dialogueA = "Great work finding all the evidence! Let's discuss what we've uncovered so far."
    private let dialogueB = "Agreed! I'll prepare the next area for investigation. Let's keep going, detective!"
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            // Background gradient for atmosphere
            LinearGradient(
                colors: [Color.indigo.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Character area
                HStack(spacing: 0) {
                    // Subject A (left side)
                    characterView(
                        subject: subjectA,
                        isActive: conversationStep == 0,
                        alignment: .leading
                    )
                    
                    Spacer()
                    
                    // Subject B (right side)
                    characterView(
                        subject: subjectB,
                        isActive: conversationStep == 1,
                        alignment: .trailing
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Dialogue text box
                if showTextBox {
                    dialogueBox
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Tap to continue hint
                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 16)
            }
        }
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showTextBox = true
            }
        }
    }
    
    // MARK: - Subviews
    
    private func characterView(subject: Subject, isActive: Bool, alignment: HorizontalAlignment) -> some View {
        VStack(spacing: 8) {
            Image(systemName: subject.avatar)
                .font(.system(size: 80))
                .foregroundStyle(subject.color)
                .opacity(isActive ? 1.0 : 0.3)
                .scaleEffect(isActive ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 0.3), value: isActive)
            
            Text(subject.name)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(isActive ? .white : .white.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }
    
    private var dialogueBox: some View {
        let currentSubject = conversationStep == 0 ? subjectA : subjectB
        let currentText = conversationStep == 0 ? dialogueA : dialogueB
        
        return VStack(alignment: .leading, spacing: 8) {
            // Speaker name tag
            Text(currentSubject.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(currentSubject.color)
            
            // Dialogue text
            Text(currentText)
                .font(.body)
                .foregroundStyle(.white)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(currentSubject.color.opacity(0.5), lineWidth: 2)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Logic
    
    private func handleTap() {
        if conversationStep == 0 {
            // Advance to Subject B
            withAnimation(.easeOut(duration: 0.3)) {
                showTextBox = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                conversationStep = 1
                withAnimation(.easeOut(duration: 0.4)) {
                    showTextBox = true
                }
            }
        } else {
            // Conversation done, return to investigation
            withAnimation(.easeOut(duration: 0.3)) {
                showTextBox = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onConversationEnd()
            }
        }
    }
}

// MARK: - Models

private struct Subject {
    let name: String
    let avatar: String
    let color: Color
}

#Preview {
    ConversationView(onConversationEnd: {
        print("Conversation ended")
    })
}
