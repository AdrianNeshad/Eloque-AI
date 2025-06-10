//
//  ChattHistory.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-10.
//
    
import Foundation

struct ChatHistory: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var lastEditedAt: Date
    let modelName: String
    
    init(id: UUID = UUID(), title: String, messages: [ChatMessage], createdAt: Date, lastEditedAt: Date, modelName: String) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.lastEditedAt = lastEditedAt
        self.modelName = modelName
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, messages, createdAt, lastEditedAt, modelName
    }
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, text, isFromUser
    }
}

@MainActor
class ChatHistoryManager: ObservableObject {
    @Published var savedChats: [ChatHistory] = []
    private let maxSavedChats = 2
        
    private var savePath: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("chat_history.json")
    }
        
    init() {
        loadChats()
    }
        
    func saveChat(id: UUID? = nil, messages: [ChatMessage], modelName: String) {
        guard !messages.isEmpty else { return }
            
        let latestUserMessage = messages.last { $0.isFromUser }?.text ?? "Chat"
        let title = String(latestUserMessage.prefix(30)) + (latestUserMessage.count > 30 ? "..." : "")
        let now = Date()
            
        if let existingChatIndex = savedChats.firstIndex(where: { $0.id == id }) {
            var updatedChat = savedChats[existingChatIndex]
            updatedChat.title = title
            updatedChat.messages = messages
            updatedChat.lastEditedAt = now
            
            savedChats[existingChatIndex] = updatedChat
            print("Updated existing chat with ID: \(id!). Title: '\(title)'")
        } else {
            let newChat = ChatHistory(
                title: title,
                messages: messages,
                createdAt: now,
                lastEditedAt: now,
                modelName: modelName
            )
            savedChats.insert(newChat, at: 0)
            print("Created new chat with ID: \(newChat.id). Title: '\(title)'")
        }
            
        savedChats.sort { $0.lastEditedAt > $1.lastEditedAt }
            
        if savedChats.count > maxSavedChats {
            savedChats = Array(savedChats.prefix(maxSavedChats))
        }
            
        saveChatsToFile()
    }
        
    func deleteChat(_ chat: ChatHistory) {
        savedChats.removeAll { $0.id == chat.id }
        saveChatsToFile()
    }
        
    func clearAllChats() {
        savedChats.removeAll()
        saveChatsToFile()
    }
        
    private func saveChatsToFile() {
        do {
            let data = try JSONEncoder().encode(savedChats)
            try data.write(to: savePath)
            print("Chat history saved to file.")
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
        
    private func loadChats() {
        do {
            let data = try Data(contentsOf: savePath)
            savedChats = try JSONDecoder().decode([ChatHistory].self, from: data)
            savedChats.sort { $0.lastEditedAt > $1.lastEditedAt }
            print("Chat history loaded from file. \(savedChats.count) chats found.")
        } catch {
            print("Failed to load chat history: \(error)")
            savedChats = []
        }
    }
}
