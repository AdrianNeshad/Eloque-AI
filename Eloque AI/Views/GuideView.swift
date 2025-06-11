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

                    Text("Welcome to Eloque AI! This guide will help you get started and make the most out of your experience interacting with AI models.")
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    Text("1. Getting Started with Eloque AI")
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    Text("Before you can begin chatting, it's essential to **choose a language model**. Go to the 'Choose Model' section to download new models or select an existing one. Once a model is active, tap 'Go to Chat' to start a new conversation. Your two most recent conversations will be saved in 'Chat History' for easy access.")
                    
                    Text("\n2. The Art of Crafting Effective Prompts")
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    Text("The quality of the AI's responses largely depends on how well you formulate your questions, or **prompts**. Here are some tips for writing better prompts:")
                        .padding(.bottom, 2)
                    
                    Text("•   **Be Clear and Specific:** Avoid ambiguity. Tell the AI exactly what you want it to do or answer. The more detailed your prompt, the more relevant the response will be.")
                        .padding(.bottom, 2)
                    Text("•   **Define the Role:** Ask the AI to act as a specific persona (e.g., 'Act as an experienced marketer...' or 'You are a friendly tutor...'). This helps the AI tailor its tone and style.")
                        .padding(.bottom, 2)
                    Text("•   **Specify Format:** If you want the answer in a particular format (e.g., a list, a table, a short paragraph), clearly state that in the prompt.")
                        .padding(.bottom, 2)
                    Text("•   **Provide Examples:** If you have a complex request, provide an example of how you want the output to look. For instance: 'Write a review like this: [example]'")
                        .padding(.bottom, 2)
                    Text("•   **Limit Length:** If you need a concise answer, ask for it. 'Respond with a maximum of 50 words' can be helpful.")
                        .padding(.bottom, 2)
                    Text("•   **Iterate and Refine:** If the first response isn't perfect, refine your prompt based on the AI's answer. It's an iterative process.")
                    
                    Text("\n3. Considerations for AI Models")
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    Text("AI models, especially those running locally, have certain characteristics you should be aware of:")
                        .padding(.bottom, 2)
                    
                    Text("•   **Model Size vs. Performance:** Larger models are often more capable but require more processing power and memory. Smaller models are faster but may be less 'intelligent.' Experiment to find a balance that suits your device and needs.")
                        .padding(.bottom, 2)
                    Text("•   **Hallucinations:** AI models can sometimes 'make up' information that isn't true (known as hallucinations). Always verify important information from the AI with reliable sources.")
                        .padding(.bottom, 2)
                    Text("•   **Limited Knowledge:** Models have a 'cutoff point' for their knowledge—they know nothing about events that occurred after the date they were trained. This is especially relevant for local models that aren't updated in real-time.")
                        .padding(.bottom, 2)
                    Text("•   **Privacy:** Since Eloque AI runs models locally on your device, your conversations are not sent to any external server. This provides a high level of privacy for your data.")
                    
                    Text("\n4. Other Tips & Troubleshooting")
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    Text("•   **Manage Models:** You can download and delete models in the 'Choose Model' section. Delete unused models to free up storage space on your device.")
                        .padding(.bottom, 2)
                    Text("•   **Performance Issues:** If the app feels slow, ensure no other demanding applications are running in the background. Another option is to try a smaller AI model that requires fewer resources.")
                        .padding(.bottom, 2)
                    Text("•   **Dark Mode:** Adjust the app's appearance in settings if you prefer dark mode.")
                        .padding(.bottom, 2)
                    Text("•   **Language:** Change the app's language in settings if you wish to change the interface language.")
                    
                    Text("\nWe hope you get great use and enjoyment out of Eloque AI!")
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
