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
    @State private var showThinkingAnimation = false
    @State private var showGuideSheet = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messages) { msg in
                            ChatBubble(text: msg.text, isFromUser: msg.isFromUser, isDarkMode: isDarkMode)
                                .id(msg.id)
                        }

                        if viewModel.isGenerating && viewModel.partialResponse?.isEmpty ?? true {
                            ChatBubble(
                                text: StringManager.shared.get("thinking") + "...",
                                isFromUser: false,
                                isDarkMode: isDarkMode,
                                showDotsAnimation: true
                            )
                            .id("ThinkingAnimationID")
                        } else if viewModel.isGenerating {
                            ChatBubble(
                                text: viewModel.partialResponse ?? "",
                                isFromUser: false,
                                isDarkMode: isDarkMode
                            )
                            .id("PartialResponseID")
                        }

                        Color.clear
                            .frame(height: 1)
                            .id("BottomID")
                    }
                }
                .coordinateSpace(name: "scroll")
                .onTapGesture {
                    isInputFieldFocused = false
                }
                .gesture(
                    DragGesture().onChanged { _ in
                        isInputFieldFocused = false
                        isUserScrollingManually = true
                    }
                )
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newOffset in
                    if isInputFieldFocused {
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
                        if !(viewModel.partialResponse?.isEmpty ?? true) {
                            proxy.scrollTo("PartialResponseID", anchor: .bottom)
                        } else if viewModel.isGenerating {
                            proxy.scrollTo("ThinkingAnimationID", anchor: .bottom)
                        } else {
                            proxy.scrollTo("BottomID", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()
                .padding(.bottom, 1)

            HStack(spacing: 10) {
                TextField("Prompt", text: $inputText, axis: .vertical)
                    .lineLimit(1...6)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(isDarkMode ? Color(.systemGray4) : Color(.systemGray5))
                    )
                    .focused($isInputFieldFocused)
                    .disabled(viewModel.isGenerating)

                Button {
                    viewModel.modelPath = modelManager.currentModelPath
                    showThinkingAnimation = true
                    viewModel.sendMessage(inputText) {
                        showThinkingAnimation = false
                    }
                    inputText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isGenerating ? .gray : .blue)
                        .padding(.horizontal, 2)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isGenerating)
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 8)
        }
        .background(isDarkMode ? Color(.systemBackground) : Color(.systemGroupedBackground))
        .navigationTitle(StringManager.shared.get("chat"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showGuideSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showGuideSheet) {
                    GuideTextView()
                        .presentationDetents([.fraction(0.8), .large])
                }
            }
        }
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
        HStack {
            Text(StringManager.shared.get("thinking"))
            Text(String(repeating: ".", count: dotCount + 1))
                .font(.body.bold())
                .onReceive(timer) { _ in
                    dotCount = (dotCount + 1) % 3
                }
                .padding(.leading, -5)
        }
    }
}
