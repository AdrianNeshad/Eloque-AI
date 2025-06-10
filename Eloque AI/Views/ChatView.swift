//
//  ChatView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var modelManager: ModelManager
    @StateObject var viewModel = ChatViewModel()
    @ObservedObject var chatHistoryManager: ChatHistoryManager
    let loadedChat: ChatHistory?
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var inputText = ""
    @State private var isUserScrollingManually = false
    @FocusState private var isInputFieldFocused: Bool
    @State private var lastContentOffset: CGFloat = 0
    @State private var showSaveAlert = false
    @Environment(\.dismiss) private var dismiss
    @State private var currentChatID: UUID?
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
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
                            .id(msg.id)
                        }
                        if viewModel.isGenerating {
                            HStack(alignment: .bottom) {
                                if let partial = viewModel.partialResponse, !partial.isEmpty {
                                    Text(partial)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                        .frame(minWidth: 120, maxWidth: 340, alignment: .leading)
                                } else {
                                    DotsAnimationView()
                                        .frame(minWidth: 120, maxWidth: 340, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id("BottomID")
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .gesture(
                    DragGesture().onChanged { _ in
                        isUserScrollingManually = true
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newOffset in
                    if newOffset > lastContentOffset && isInputFieldFocused {
                        isInputFieldFocused = false
                    }
                    lastContentOffset = newOffset
                }
                .onChange(of: viewModel.messages.count) {
                    isUserScrollingManually = false
                    proxy.scrollTo("BottomID", anchor: .bottom)
                    saveCurrentChat()
                }
                .onChange(of: viewModel.partialResponse) {
                    if !isUserScrollingManually {
                        proxy.scrollTo("BottomID", anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Prompt...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isGenerating)
                    .focused($isInputFieldFocused)
                
                Button(StringManager.shared.get("send")) {
                    viewModel.modelPath = modelManager.currentModelPath
                    viewModel.sendMessage(inputText) {
                    }
                    inputText = ""
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isGenerating)
            }
            .padding()
        }
        .navigationTitle(StringManager.shared.get("chat"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let loadedChat = loadedChat {
                viewModel.loadChat(loadedChat)
                currentChatID = loadedChat.id
                Task {
                    do {
                        let modelURL = modelManager.fileHelper.modelsDirectory.appendingPathComponent("\(loadedChat.modelName).gguf")
                        if FileManager.default.fileExists(atPath: modelURL.path) {
                            try await modelManager.loadModel(at: modelURL)
                        } else {
                            print("Model file for loaded chat not found: \(modelURL.lastPathComponent)")
                        }
                    } catch {
                        print("Failed to load model for loaded chat: \(error.localizedDescription)")
                    }
                }
            } else {
                currentChatID = nil
            }
            viewModel.modelPath = modelManager.currentModelPath
        }
    }
    
    private func saveCurrentChat() {
        guard !viewModel.messages.isEmpty,
              let modelPath = modelManager.currentModelPath else { return }
        
        let modelName = URL(fileURLWithPath: modelPath).deletingPathExtension().lastPathComponent
        
        chatHistoryManager.saveChat(id: currentChatID, messages: viewModel.messages, modelName: modelName)
        
        if currentChatID == nil, let firstChat = chatHistoryManager.savedChats.first {
            currentChatID = firstChat.id
            print("Assigned new chat ID: \(currentChatID!)")
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DotsAnimationView: View {
    @State private var dotCount = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(String(repeating: ".", count: dotCount + 1))
            .font(.body.bold())
            .onReceive(timer) { _ in
                dotCount = (dotCount + 1) % 3
            }
    }
}
