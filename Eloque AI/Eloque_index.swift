//
//  ContentView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelManager: ModelManager
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"

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

                    NavigationLink(destination: ChatView()) {
                        Text(StringManager.shared.get("gotochat"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.4))
                            .cornerRadius(10)
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
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ModelManager())
}
