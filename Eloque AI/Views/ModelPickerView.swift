//
//  ModelPickerView.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import SwiftUI

struct ModelPickerView: View {
    @EnvironmentObject var modelManager: ModelManager
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("appLanguage") private var appLanguage = "en"
    @State private var errorMessage: String? = nil
    @State private var showingErrorAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var modelToDelete: LLMModelInfo? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(modelManager.availableModels) { model in
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 0) { 
                            VStack(alignment: .leading) {
                                Text(model.name)
                                    .font(.title)
                                    .bold()
                                    .padding(.bottom, 5)
                                
                                Text(model.description)
                                    .font(.subheadline)
                                    .padding(.bottom, 10)
                                 
                                HStack {
                                    Text(StringManager.shared.get("size"))
                                    Text("\(model.sizeMB)")
                                        .padding(.leading, -5)
                                    Text("MB")
                                        .padding(.leading, -5)
                                    Spacer()
                                    Text(StringManager.shared.get("recommended"))
                                }
                                .font(.subheadline)
                                .padding(.bottom, -12)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.horizontal, .top])
                            
                            HStack(spacing: 8) {
                                if let progress = modelManager.downloadProgress[model.name] {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            ProgressView(value: progress)
                                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                                .frame(height: 6)
                                                .scaleEffect(y: 1.5)
                                            
                                            Text("\(Int(progress * 100))%")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .monospacedDigit()
                                        }
                                        Text(StringManager.shared.get("downloading"))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else if modelManager.isDownloading[model.name] == true {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                                .frame(height: 6)
                                            
                                            Text("0%")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .monospacedDigit()
                                        }
                                        Text(StringManager.shared.get("downloading"))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else if modelManager.isModelDownloaded(model) {
                                    Button(role: .destructive) {
                                        modelToDelete = model
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label(StringManager.shared.get("delete"), systemImage: "trash")
                                    }
                                } else {
                                    Button(StringManager.shared.get("download"), systemImage: "square.and.arrow.down") {
                                        Task {
                                            do {
                                                _ = try await modelManager.downloadModel(model)
                                            } catch {
                                                errorMessage = "Nedladdning misslyckades: \(error.localizedDescription)"
                                                showingErrorAlert = true
                                            }
                                        }
                                    }
                                    .foregroundColor(.blue)
                                }
                                Spacer()
                                
                                ForEach(model.compatibleDevices, id: \.self) { device in
                                    if let iconName = model.systemIconName(for: device) {
                                        Image(systemName: iconName)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding([.horizontal, .bottom])
                            .padding(.top, 20)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isDarkMode ? Color(.secondarySystemBackground) : Color.gray.opacity(0.2))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if modelManager.isModelDownloaded(model) && modelManager.isDownloading[model.name] != true {
                                Task {
                                    do {
                                        let url = modelManager.fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
                                        try await modelManager.loadModel(at: url)
                                    } catch {
                                        errorMessage = "Kunde inte ladda modellen: \(error.localizedDescription)"
                                        showingErrorAlert = true
                                    }
                                }
                            }
                        }
                        
                        if modelManager.isModelDownloaded(model) {
                            Image(systemName: modelManager.isModelSelected(model) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(modelManager.isModelSelected(model) ? .green : .gray)
                                .font(.title2)
                                .padding(20)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .task {
            if modelManager.availableModels.isEmpty {
                try? await modelManager.loadAvailableModels()
            }
        }
        .navigationTitle(StringManager.shared.get("models"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddModel()) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .confirmationDialog(StringManager.shared.get("suredeletemodel"), isPresented: $showingDeleteConfirmation, presenting: modelToDelete) { model in
            Button(StringManager.shared.get("delete") + " \(model.name)\"", role: .destructive) {
                Task {
                    do {
                        try modelManager.deleteModel(model)
                    } catch {
                        errorMessage = "Error: \(error.localizedDescription)"
                        showingErrorAlert = true
                    }
                } 
            }
            Button(StringManager.shared.get("cancel"), role: .cancel) { }
        } message: { model in
            Text(StringManager.shared.get("deletemodelmessage") + " \"\(model.name)\"?")
        }
    }
}
