//
//  SafariView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-11.
//

import SwiftUI

struct GuideTextView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Comprehensive Guide to Eloque AI")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 5)

                    Text("Welcome to Eloque AI! This guide will help you get started and make the most out of your experience.")
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    Text("Getting Started:")
                        .font(.headline)
                    Text("1. **Choose a Model:** Before you begin chatting, select a language model from the 'Choose Model' section. You can download new models or select an existing one.")
                    Text("2. **Start a New Chat:** Once a model is chosen, tap 'Go to Chat' to begin a fresh conversation.")
                    Text("3. **Continue Existing Chats:** Your two most recent conversations will appear under 'Chat History'. Tap on one to pick up where you left off.")
                    
                    Text("\nChatting with AI:")
                        .font(.headline)
                    Text("Type your prompts into the text field at the bottom of the chat screen. The AI will generate responses based on the loaded model.")
                    
                    Text("\nTips for Best Results:")
                        .font(.headline)
                    Text("- **Be Clear and Specific:** The more precise your prompt, the better the AI can understand and respond.")
                    Text("- **Experiment with Models:** Different models have different strengths. Try various models for different types of conversations or tasks.")
                    Text("- **Context is Key:** In ongoing conversations, the AI remembers previous turns, so keep your dialogue coherent.")
                    
                    Text("\nManaging Models:")
                        .font(.headline)
                    Text("You can manage your downloaded models in the 'Choose Model' section. Delete models you no longer need to free up space.")
                    
                    Text("\nTroubleshooting:")
                        .font(.headline)
                    Text("If you encounter issues, ensure you have a model loaded. For performance problems, consider trying a smaller model or closing other demanding apps.")
                    
                    Text("\nEnjoy your AI conversations!")
                        .font(.body)
                        .padding(.top, 10)

                }
                .padding()
            }
            .navigationTitle("Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(StringManager.shared.get("close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GuideTextView_Previews: PreviewProvider {
    static var previews: some View {
        GuideTextView()
    }
}
