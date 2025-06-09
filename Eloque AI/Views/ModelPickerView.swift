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
    @State private var downloadingModelName: String? = nil
    
    var body: some View {
        List(modelManager.availableModels) { model in
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 5)
                Text(model.description)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                Text("Size: \(model.sizeMB) MB")
                    .font(.subheadline)
                Button(StringManager.shared.get("download")) {
                    Task {
                        let url = try await modelManager.downloadModel(model)
                        try await modelManager.loadModel(at: url)
                    }
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDarkMode ? Color(.secondarySystemBackground) : Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .listRowInsets(EdgeInsets())
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
        }
        .listStyle(PlainListStyle())
        .task {
            try? await modelManager.loadAvailableModels()
        }
        .navigationTitle(StringManager.shared.get("models"))
    }
}
