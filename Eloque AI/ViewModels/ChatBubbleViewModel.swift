//
//  ChattBubbleModel.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-12.
//

import Foundation
import SwiftUI

struct Part: Hashable {
    let content: String
    let isCode: Bool
}

func parseTextParts(_ text: String) -> [Part] {
    var parts: [Part] = []
    let regex = try! NSRegularExpression(pattern: "(?s)```([\\w]*)\\n(.*?)```", options: [])
    var lastIndex = text.startIndex

    let nsrange = NSRange(text.startIndex..., in: text)
    let matches = regex.matches(in: text, options: [], range: nsrange)

    for match in matches {
        let rangeBefore = lastIndex..<text.index(text.startIndex, offsetBy: match.range.lowerBound)
        let before = String(text[rangeBefore])
        if !before.isEmpty {
            parts.append(Part(content: before, isCode: false))
        }
        if let codeRange = Range(match.range(at: 2), in: text) {
            let codeContent = String(text[codeRange])
            parts.append(Part(content: "```\n\(codeContent)\n```", isCode: true))
        }
        lastIndex = text.index(text.startIndex, offsetBy: match.range.upperBound)
    }
    if lastIndex < text.endIndex {
        let after = String(text[lastIndex...])
        if !after.isEmpty {
            parts.append(Part(content: after, isCode: false))
        }
    }
    return parts.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
