//
//  ChatViewModel.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//
    
import Foundation
import Kuzco
import SwiftUI // Make sure SwiftUI is imported if you use @AppStorage

@MainActor
class ChatViewModel: ObservableObject {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var partialResponse: String? = nil
    
    var modelPath: String?
    
    func sendMessage(_ prompt: String, completion: (() -> Void)? = nil) {
        messages.append(ChatMessage(text: prompt, isFromUser: true))
        isGenerating = true
        partialResponse = ""

        Task {
            guard let path = modelPath else {
                messages.append(ChatMessage(text: "⚠️ No model chosen", isFromUser: false))
                isGenerating = false
                partialResponse = nil
                completion?()
                return
            }
            
            let formatter: InteractionFormatting
            if path.contains("deepseek") || path.contains("zephyr") || path.contains("chatml") {
                formatter = ChatMLInteractionFormatter()
            } else {
                formatter = StandardInteractionFormatter()
            }
            
            do {
                let profile = ModelProfile(sourcePath: path, architecture: .llamaGeneral)
                let instance = await LlamaInstance(
                    profile: profile,
                    settings: InstanceSettings(),
                    predictionConfig: PredictionConfig(),
                    formatter: formatter
                )

                let startupStream = await instance.startup()
                var isReady = false
                for await update in startupStream {
                    if update.stage == .ready {
                        isReady = true
                        break
                    } else if update.stage == .failed {
                        throw NSError(domain: "Model failed to start", code: -1)
                    }
                }
                guard isReady else {
                    throw NSError(domain: "Model not ready after startup", code: -2)
                }
                
                let dialogue = [ Turn(role: .user, text: prompt) ]
                let stream = await instance.generate(dialogue: dialogue)
                
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
            completion?()
        }
    }
    
    func loadChat(_ chatHistory: ChatHistory) {
        messages = chatHistory.messages
    }
    
    func clearMessages() {
        messages.removeAll()
        partialResponse = nil
    }
}
