//
//  ChatBubble.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-11.
//

import SwiftUI
import MarkdownUI

struct ChatBubbleView: View {
    let text: String
    let isFromUser: Bool
    let isDarkMode: Bool
    var showDotsAnimation: Bool = false
    
    var body: some View {
        HStack {
            if !isFromUser { Spacer() }
            VStack(alignment: isFromUser ? .trailing : .leading, spacing: 0) {
                if showDotsAnimation {
                    DotsAnimationView()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(
                            LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .foregroundColor(isDarkMode ? .white : .black)
                        .cornerRadius(22)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(parseTextParts(text), id: \.self) { part in
                        if part.isCode {
                            Markdown(part.content)
                                .markdownTheme(.gitHub)
                                .padding(8)
                                .background(isDarkMode ? Color(.systemGray6) :  Color(.systemGray4))
                                .cornerRadius(14)
                                .padding(.vertical, 3)
                                .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
                        } else {
                            if let attributedString = try? AttributedString(markdown: part.content) {
                                Text(attributedString)
                                    .textSelection(.enabled)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 18)
                                    .background(
                                        isFromUser
                                        ? LinearGradient(colors: [Color.blue, Color.blue.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .foregroundColor(isFromUser ? .white : (isDarkMode ? .white : .black))
                                    .cornerRadius(22)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
                            } else {
                                Text(part.content)
                                    .textSelection(.enabled)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 18)
                                    .background(
                                        isFromUser
                                        ? LinearGradient(colors: [Color.blue, Color.blue.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .foregroundColor(isFromUser ? .white : (isDarkMode ? .white : .black))
                                    .cornerRadius(22)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 5)
            .padding(isFromUser ? .leading : .trailing, 25)
            .padding(isFromUser ? .trailing : .leading, 5)
            if isFromUser { Spacer() }
        }
    }
}
