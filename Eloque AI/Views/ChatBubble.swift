//
//  ChatBubble.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-11.
//

import SwiftUI

struct ChatBubble: View {
    let text: String
    let isFromUser: Bool
    let isDarkMode: Bool
    var showDotsAnimation: Bool = false

    var body: some View {
        HStack {
            if !isFromUser { Spacer() }
            
            Group {
                if showDotsAnimation {
                    DotsAnimationView()
                } else {
                    Text(text)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(
                isFromUser
                    ? LinearGradient(colors: [Color.blue, Color.blue.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(isFromUser ? .white : (isDarkMode ? .white : .black))
            .cornerRadius(22)
            .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
            
            if isFromUser { Spacer() }
        }
        .padding(.vertical, 10)
        .padding(isFromUser ? .leading : .trailing, 25)
        .padding(isFromUser ? .trailing : .leading, 5)
    }
}
