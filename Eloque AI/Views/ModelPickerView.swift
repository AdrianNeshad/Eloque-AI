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
    
    @State private var errorMessage: String? = nil
    @State private var showingErrorAlert = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(modelManager.availableModels) { model in
                    VStack(alignment: .leading) {
                        Button {
                            Task {
                                do {
                                    let url = modelManager.fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
                                    if FileManager.default.fileExists(atPath: url.path) {
                                        try await modelManager.loadModel(at: url)
                                    } else {
                                    }
                                } catch {
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                HStack(spacing: 0) {
                                    if modelManager.isModelSelected(model) {
                                        Label("", systemImage: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                    }
                                    Text(model.name)
                                        .font(.title)
                                        .bold()
                                }
                                Text(model.description)
                                    .font(.subheadline)
                                    .padding(.bottom, 10)
                                Text("Size: \(model.sizeMB) MB")
                                    .font(.subheadline)
                                    .padding(.bottom, -12)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        HStack {
                            if let progress = modelManager.downloadProgress[model.name] {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        ProgressView(value: progress)
                                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                            .frame(height: 4)
                                    }
                                    Text("Downloading... \(Int(progress * 100))%")
                                        .font(.caption) 
                                }
                            } else if modelManager.isModelDownloaded(model) {
                                Button(role: .destructive) {
                                    do {
                                        try modelManager.deleteModel(model)
                                    } catch {
                                        errorMessage = "Kunde inte radera modellen: \(error.localizedDescription)"
                                        showingErrorAlert = true
                                    }
                                } label: {
                                    Label("Radera", systemImage: "trash")
                                }
                            } else {
                                Button(StringManager.shared.get("download")) {
                                    Task {
                                        do {
                                            let url = try await modelManager.downloadModel(model)
                                            try await modelManager.loadModel(at: url)
                                        } catch {
                                            errorMessage = "Nedladdningen misslyckades: \(error.localizedDescription)"
                                            showingErrorAlert = true
                                        }
                                    }
                                }
                                .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isDarkMode ? Color(.secondarySystemBackground) : Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .task {
            try? await modelManager.loadAvailableModels()
        }
        .navigationTitle(StringManager.shared.get("models"))
        .alert("Fel", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
