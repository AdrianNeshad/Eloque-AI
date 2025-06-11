//
//  AddModel.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-11.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddModel: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var modelManager: ModelManager
    @State private var selectedFileURL: URL? = nil
    @State private var showingFileImporter = false
    @State private var modelName = ""
    @State private var description = "Custom local model"
    @State private var selectedArchitecture: ModelArchitectureType? = nil
    @State private var sizeMB: Int = 0
    @State private var errorMessage: String? = nil
    @State private var showError = false
    
    enum ModelArchitectureType: String, CaseIterable, Identifiable, Codable {
        case llama3 = "LLaMA 3"
        case llamaGeneral = "LLaMA General"
        case mistral = "Mistral Instruct"
        case phi = "Phi"
        case gemma = "Gemma"
        case openchat = "OpenChat"
        var id: String { rawValue }
    }
    
    var body: some View {
        Form {
            Section(header: Text("GGUF-file")) {
                Button(StringManager.shared.get("choosefile")) {
                    showingFileImporter = true
                }
                .fileImporter(
                    isPresented: $showingFileImporter,
                    allowedContentTypes: [UTType(filenameExtension: "gguf")!],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        guard let url = try result.get().first else { return }
                        var didStartAccessing = false
                        if url.startAccessingSecurityScopedResource() {
                            didStartAccessing = true
                        }
                        defer {
                            if didStartAccessing {
                                url.stopAccessingSecurityScopedResource()
                            }
                        }
                        selectedFileURL = url
                        modelName = url.deletingPathExtension().lastPathComponent
                        if let fileSizeNum = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber {
                            sizeMB = Int(Double(fileSizeNum.intValue) / 1024 / 1024)
                        } else {
                            sizeMB = 0
                        }
                    } catch {
                        errorMessage = "Error"
                        showError = true
                    }
                }
                if let url = selectedFileURL {
                    Text("Fil: \(url.lastPathComponent)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text(StringManager.shared.get("architecture"))) {
                Picker(StringManager.shared.get("architecture"), selection: $selectedArchitecture) {
                    ForEach(ModelArchitectureType.allCases) { type in
                        Text(type.rawValue).tag(type as ModelArchitectureType?)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section(header: Text(StringManager.shared.get("name"))) {
                TextField(StringManager.shared.get("name"), text: $modelName)
            }
            
            Button(StringManager.shared.get("addmodel")) {
                addCustomModel()
            }
            .disabled(selectedFileURL == nil || selectedArchitecture == nil || modelName.isEmpty)
        }
        .navigationTitle(StringManager.shared.get("addmodel"))
        .alert("Error", isPresented: $showError, actions: { Button("OK", role: .cancel) {} }, message: {
            Text(errorMessage ?? "Error")
        })
    }
    
    func addCustomModel() {
        guard let url = selectedFileURL, let arch = selectedArchitecture else {
            errorMessage = StringManager.shared.get("architecture")
            showError = true
            return
        }
        let destination = modelManager.fileHelper.modelsDirectory.appendingPathComponent("\(modelName).gguf")
        var didStartAccessing = false
        if url.startAccessingSecurityScopedResource() {
            didStartAccessing = true
        }
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            if url != destination {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: url, to: destination)
            }
            
            let newModel = LLMModelInfo(
                name: modelName,
                url: destination,
                sizeMB: sizeMB,
                description: description + " (\(arch.rawValue))",
                compatibility: "custom"
            )
            modelManager.availableModels.append(newModel)
            modelManager.saveAvailableModels()   
            dismiss()
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            showError = true
        }
    }
}
