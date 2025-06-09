//
//  ChatMLInteractionFormatter.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import Foundation

class ChatMLInteractionFormatter: InteractionFormatting {
    func constructPrompt(for dialogue: [Turn], modelArchitecture: ModelArchitecture, systemPrompt: String?) -> String {
        var prompt = ""
        if let systemPrompt = systemPrompt, !systemPrompt.isEmpty {
            prompt += "<|im_start|>system\n\(systemPrompt)\n<|im_end|>\n"
        }
        for turn in dialogue {
            switch turn.role {
            case .user:
                prompt += "<|im_start|>user\n\(turn.text)\n<|im_end|>\n"
            case .assistant:
                prompt += "<|im_start|>assistant\n\(turn.text)\n<|im_end|>\n"
            }
        }
        prompt += "<|im_start|>assistant\n"
        return prompt
    }
}
