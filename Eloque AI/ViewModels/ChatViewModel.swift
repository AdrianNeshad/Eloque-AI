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
    @Published var messages: [ChatMessage] = []
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    var modelPath: String?

    func sendMessage(_ prompt: String) {
        messages.append(ChatMessage(text: prompt, isFromUser: true))

        Task {
            guard let path = modelPath else {
                messages.append(ChatMessage(text: "⚠️ No model chosen", isFromUser: false))
                return
            }

            do {
                let profile = ModelProfile(sourcePath: path, architecture: .llamaGeneral)
                let dialogue = [ Turn(role: .user, text: prompt) ]

                let stream = try await Kuzco.shared.predict(
                    dialogue: dialogue,
                    with: profile,
                    instanceSettings: InstanceSettings(),
                    predictionConfig: PredictionConfig()
                )

                var response = ""
                for try await token in stream {
                    response += token
                }

                messages.append(ChatMessage(text: response, isFromUser: false))

            } catch {
                messages.append(ChatMessage(text: "⚠️ Error: \(error.localizedDescription)", isFromUser: false))
            }
        }
    }
}
