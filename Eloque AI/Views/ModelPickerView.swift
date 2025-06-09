//
//  ModelPickerView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

struct ModelPickerView: View {
    @EnvironmentObject var modelManager: ModelManager
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    var body: some View {
        List(modelManager.availableModels) { model in
            VStack(alignment: .leading) {
                Text(model.name).font(.title).bold().padding(.bottom, 5)
                Text(model.description).font(.subheadline).padding(.bottom, 10)
                Text("Size: \(model.sizeMB) MB").font(.subheadline)
                Button(StringManager.shared.get("download")) {
                    Task {
                        let url = try await modelManager.downloadModel(model)
                        try await modelManager.loadModel(at: url)
                    }
                }
            }
            .padding()
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .task {
            try? await modelManager.loadAvailableModels()
        }
        .navigationTitle(StringManager.shared.get("models"))
    }
}
