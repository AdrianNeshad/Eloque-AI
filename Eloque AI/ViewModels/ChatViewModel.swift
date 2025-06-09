//
//  ChatViewModel.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//
    
import Foundation
import Kuzco
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var partialResponse: String? = nil
    
    var modelPath: String?

    func sendMessage(_ prompt: String) {
        messages.append(ChatMessage(text: prompt, isFromUser: true))
        isGenerating = true
        partialResponse = ""

        Task {
            guard let path = modelPath else {
                messages.append(ChatMessage(text: "⚠️ No model chosen", isFromUser: false))
                isGenerating = false
                partialResponse = nil
                return
            }
            
            // --- Välj formatter beroende på filnamnet/modellnamnet ---
            let formatter: InteractionFormatting
            if path.contains("deepseek") || path.contains("zephyr") || path.contains("chatml") {
                formatter = ChatMLInteractionFormatter()
            } else {
                formatter = StandardInteractionFormatter() // eller vad din "default" heter
            }
            
            do {
                let profile = ModelProfile(sourcePath: path, architecture: .llamaGeneral)
                let dialogue = [ Turn(role: .user, text: prompt) ]
                
                let stream = try await Kuzco.shared.predict(
                    dialogue: dialogue,
                    with: profile,
                    instanceSettings: InstanceSettings(),
                    predictionConfig: PredictionConfig(),
                    interactionFormatter: formatter // <-- Skicka in formattern här!
                )

                var response = ""
                for try await token in stream {
                    response += token
                    await MainActor.run {
                        self.partialResponse = response
                    }
                }
                messages.append(ChatMessage(text: response, isFromUser: false))
            } catch {
                messages.append(ChatMessage(text: "⚠️ Error: \(error.localizedDescription)", isFromUser: false))
            }
            isGenerating = false
            partialResponse = nil
        }
    }
}
