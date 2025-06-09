//
//  ChatView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var modelManager: ModelManager
    @StateObject var viewModel = ChatViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { msg in
                        HStack {
                            if msg.isFromUser { Spacer() }
                            Text(msg.text)
                                .padding()
                                .background(msg.isFromUser ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(msg.isFromUser ? .white : (isDarkMode ? .white : .black))
                                .cornerRadius(16)
                            if !msg.isFromUser { Spacer() }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            HStack {
                TextField("Prompt...", text: $inputText)
                    .textFieldStyle(.roundedBorder)

                Button(StringManager.shared.get("send")) {
                    viewModel.modelPath = modelManager.currentModelPath
                    viewModel.sendMessage(inputText)
                    inputText = ""
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(StringManager.shared.get("chat"))
    }
}
