//
//  ChattHistory.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-10.
//
    
import Foundation

struct ChatHistory: Identifiable, Codable {
    let id = UUID()
    let title: String
    let messages: [ChatMessage]
    let createdAt: Date
    let modelName: String
    
    private enum CodingKeys: String, CodingKey {
        case id, title, messages, createdAt, modelName
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
    
    func saveChat(messages: [ChatMessage], modelName: String) {
        guard !messages.isEmpty else { return }
        
        let firstUserMessage = messages.first { $0.isFromUser }?.text ?? "Chat"
        let title = String(firstUserMessage.prefix(30)) + (firstUserMessage.count > 30 ? "..." : "")
        
        let newChat = ChatHistory(
            title: title,
            messages: messages,
            createdAt: Date(),
            modelName: modelName
        )
        
        savedChats.insert(newChat, at: 0)
        
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
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
    
    private func loadChats() {
        do {
            let data = try Data(contentsOf: savePath)
            savedChats = try JSONDecoder().decode([ChatHistory].self, from: data)
        } catch {
            print("Failed to load chat history: \(error)")
            savedChats = []
        }
    }
}
