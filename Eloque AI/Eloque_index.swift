//
//  ContentView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelManager: ModelManager
    @StateObject private var chatHistoryManager = ChatHistoryManager()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var showNoModelAlert = false
    @State private var showChatView = false
    @State private var selectedChat: ChatHistory?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                    Text("Eloque AI")
                        .font(.largeTitle)
                        .bold()
                }
                .scaleEffect(1.5)
                .padding(.bottom, 150)
                .padding(.top, 100)
                Text(StringManager.shared.get("Index_banner"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let currentPath = modelManager.currentModelPath {
                    HStack {
                        Text(StringManager.shared.get("chosenmodel"))
                        Text("\(URL(fileURLWithPath: currentPath).lastPathComponent)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                } else {
                    Text(StringManager.shared.get("nomodelchosen"))
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }

                VStack(spacing: 16) {
                    NavigationLink(destination: ModelPickerView()) {
                        Text(StringManager.shared.get("choosemodel"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button {
                        if modelManager.currentModelPath == nil {
                            showNoModelAlert = true
                        } else {
                            selectedChat = nil
                            showChatView = true
                        }
                    } label: {
                        Text(StringManager.shared.get("gotochat"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.4))
                            .cornerRadius(10)
                    }
                    .alert(StringManager.shared.get("choosemodelfirst"), isPresented: $showNoModelAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(StringManager.shared.get("choosemodelfirsttext"))
                    }
                    
                    if !chatHistoryManager.savedChats.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(StringManager.shared.get("chathistory"))
                                    .font(.headline)
                                    .padding(.leading, 4)
                                Spacer()
                                Text("(Max 2)")
                                .font(.caption)
                            }
                            
                            ForEach(chatHistoryManager.savedChats) { chat in
                                Button {
                                    if modelManager.currentModelPath == nil {
                                        showNoModelAlert = true
                                    } else {
                                        selectedChat = chat
                                        showChatView = true
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(chat.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(1)
                                            
                                            HStack {
                                                Text(chat.modelName)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text(formatDate(chat.createdAt))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Button {
                                            chatHistoryManager.deleteChat(chat)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .font(.caption)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.4))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .id(modelManager.currentModelPath)
            .navigationTitle("")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: Settings()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationDestination(isPresented: $showChatView) {
                ChatView(
                    chatHistoryManager: chatHistoryManager,
                    loadedChat: selectedChat
                )
            }
        }
        .environmentObject(chatHistoryManager)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environmentObject(ModelManager())
}
