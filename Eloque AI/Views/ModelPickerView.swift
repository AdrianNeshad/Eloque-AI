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

    var body: some View {
        List(modelManager.availableModels) { model in
            VStack(alignment: .leading) {
                Text(model.name).font(.headline)
                Text(model.description).font(.subheadline)
                Text("Size: \(model.sizeMB) MB").font(.caption)
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
        .navigationTitle("AI-Modeller")
    }
}
