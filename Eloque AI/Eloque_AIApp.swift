//
//  Eloque_AIApp.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

@main
struct Eloque_AIApp: App {
    @StateObject var modelManager = ModelManager()
    @StateObject var chatHistoryManager = ChatHistoryManager()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelManager)
                .environmentObject(chatHistoryManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .task {
                    do {
                        try await modelManager.loadAvailableModels()
                        await modelManager.loadLastSelectedModel()
                    } catch {
                        print("Failed to load models or last selected model: \(error)")
                    }
                }
                .onAppear {
                    if !hasLaunchedBefore {
                        modelManager.prepareModelList()    
                        setLanguageFromSystem()
                        setDarkModeFromSystem()
                        hasLaunchedBefore = true
                    }
                }
        }
    }

    func setLanguageFromSystem() {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.starts(with: "sv") {
            appLanguage = "sv"
        } else {
            appLanguage = "en"
        }
    }

    func setDarkModeFromSystem() {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            isDarkMode = true
        } else {
            isDarkMode = false
        }
    }
}
