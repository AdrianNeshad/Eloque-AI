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
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .onAppear {
                    if !hasLaunchedBefore {
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
