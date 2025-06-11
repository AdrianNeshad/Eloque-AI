//
//  ModelManager.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

@preconcurrency import Kuzco
import Foundation
import SwiftUI

@MainActor
class ModelManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("lastSelectedModel") private var lastSelectedModelName = ""
    @Published var availableModels: [LLMModelInfo] = []
    @Published var currentModel: LlamaInstance?
    @Published var downloadProgress: [String: Double] = [:]
    @Published var isDownloading: [String: Bool] = [:]
    
    private var currentProfile: ModelProfile?
    let fileHelper = FileHelper()
    private var downloadContinuations: [String: CheckedContinuation<URL, Error>] = [:]
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func prepareModelList() {
        let fileManager = FileManager.default
        let docs = fileHelper.modelsDirectory
        let modelListURL = docs.appendingPathComponent("ModelList.json")
        
        if !fileManager.fileExists(atPath: modelListURL.path) {
            if let bundleURL = Bundle.main.url(forResource: "ModelList", withExtension: "json") {
                do {
                    try fileManager.copyItem(at: bundleURL, to: modelListURL)
                } catch {
                    print("Error copying ModelList.json from bundle: \(error.localizedDescription)")
                }
            } else {
                let emptyList: [LLMModelInfo] = []
                if let data = try? JSONEncoder().encode(emptyList) {
                    try? data.write(to: modelListURL)
                }
            }
        }
    }
    
    func loadAvailableModels() async throws {
        let docs = fileHelper.modelsDirectory
        let url = docs.appendingPathComponent("ModelList.json")
        
        var modelsFromFile: [LLMModelInfo] = []
        if let data = try? Data(contentsOf: url), !data.isEmpty {
            modelsFromFile = (try? JSONDecoder().decode([LLMModelInfo].self, from: data)) ?? []
        }
        
        var bundleModels: [LLMModelInfo] = []
        if let bundleURL = Bundle.main.url(forResource: "ModelList", withExtension: "json"),
           let bundleData = try? Data(contentsOf: bundleURL) {
            bundleModels = (try? JSONDecoder().decode([LLMModelInfo].self, from: bundleData)) ?? []
        }
        
        var combinedModels = bundleModels
        for localModel in modelsFromFile {
            if !combinedModels.contains(where: { $0.name == localModel.name }) {
                combinedModels.append(localModel)
            }
        }
        
        DispatchQueue.main.async {
            self.availableModels = combinedModels.sorted { $0.name < $1.name }
        }
    }
    
    func saveAvailableModels() {
        let docs = fileHelper.modelsDirectory
        let url = docs.appendingPathComponent("ModelList.json")
        
        if let bundleURL = Bundle.main.url(forResource: "ModelList", withExtension: "json"),
           let bundleData = try? Data(contentsOf: bundleURL),
           let bundleModels = try? JSONDecoder().decode([LLMModelInfo].self, from: bundleData) {
            
            let customModels = self.availableModels.filter { model in
                !bundleModels.contains(where: { $0.name == model.name })
            }
            
            if let data = try? JSONEncoder().encode(customModels) {
                do {
                    try data.write(to: url)
                } catch {
                    print("Error saving available models: \(error.localizedDescription)")
                }
            }
        } else {
            if let data = try? JSONEncoder().encode(self.availableModels) {
                do {
                    try data.write(to: url)
                } catch {
                    print("Error saving available models (fallback): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func initialize() {
        prepareModelList()
        Task {
            try? await loadAvailableModels()
        }
    }
    
    @MainActor
    func loadLastSelectedModel() async {
        guard !lastSelectedModelName.isEmpty else { return }
        let modelURL = fileHelper.modelsDirectory.appendingPathComponent("\(lastSelectedModelName).gguf")
        if FileManager.default.fileExists(atPath: modelURL.path) {
            do {
                try await loadModel(at: modelURL)
                print("Loaded last selected model: \(lastSelectedModelName)")
            } catch {
                print("Failed to load last selected model: \(error)")
                lastSelectedModelName = ""
            }
        } else {
            lastSelectedModelName = ""
        }
    }
    
    func downloadModel(_ model: LLMModelInfo) async throws -> URL {
        self.downloadProgress[model.name] = 0.0
        self.isDownloading[model.name] = true
        
        return try await withCheckedThrowingContinuation { continuation in
            downloadContinuations[model.name] = continuation
            
            let downloadTask = session.downloadTask(with: model.url)
            downloadTask.taskDescription = model.name
            downloadTask.resume()
        }
    }
    
    func loadModel(at url: URL) async throws {
        let profile = ModelProfile(sourcePath: url.path, architecture: .llamaGeneral)
        self.currentProfile = profile
        
        let instance = await LlamaInstance(
            profile: profile,
            settings: InstanceSettings(),
            predictionConfig: PredictionConfig()
        )
        self.currentModel = instance
        
        let modelName = url.deletingPathExtension().lastPathComponent
        lastSelectedModelName = modelName
    }
    
    func isModelDownloaded(_ model: LLMModelInfo) -> Bool {
        let fileURL = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func deleteModel(_ model: LLMModelInfo) throws {
        let fileURL = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.removeItem(at: fileURL)
                print("Successfully deleted model file: \(fileURL.lastPathComponent)")
            } catch {
                print("Error deleting model file \(fileURL.lastPathComponent): \(error.localizedDescription)")
                throw error
            }
        } else {
            print("Model file not found at path: \(fileURL.path). Proceeding with list removal if custom.")
        }
        
        if model.compatibility == "custom" {
            DispatchQueue.main.async {
                self.availableModels.removeAll { $0.name == model.name }
                self.saveAvailableModels()
                print("Removed custom model '\(model.name)' from availableModels list and saved.")
            }
        } else {
            print("Preloaded model '\(model.name)' file deleted, but kept in availableModels list.")
        }
        
        if currentProfile?.sourcePath == fileURL.path {
            DispatchQueue.main.async {
                self.currentProfile = nil
                self.currentModel = nil
                print("Deselected currently loaded model '\(model.name)'.")
            }
        }
        if lastSelectedModelName == model.name {
            DispatchQueue.main.async {
                self.lastSelectedModelName = ""
                print("Cleared last selected model '\(model.name)'.")
            }
        }
    }
    
    func isModelSelected(_ model: LLMModelInfo) -> Bool {
        currentModelPath == fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf").path
    }
    
    var currentModelPath: String? {
        currentProfile?.sourcePath
    }
    
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let modelName = downloadTask.taskDescription else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        Task { @MainActor in
            self.downloadProgress[modelName] = progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let modelName = downloadTask.taskDescription,
              let continuation = downloadContinuations[modelName] else { return }
        
        Task { @MainActor in
            self.downloadProgress[modelName] = nil
            self.isDownloading[modelName] = false
            self.downloadContinuations.removeValue(forKey: modelName)
        }
        
        do {
            let destination = fileHelper.modelsDirectory.appendingPathComponent("\(modelName).gguf")
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: location, to: destination)
            let attrs = try FileManager.default.attributesOfItem(atPath: destination.path)
            if let fileSize = attrs[.size] as? NSNumber {
                if fileSize.intValue < 10_000_000 {
                    try FileManager.default.removeItem(at: destination)
                    continuation.resume(throwing: NSError(domain: "ModelManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download failed. Server denied download"]))
                    return
                }
            }
            continuation.resume(returning: destination)
        } catch {
            continuation.resume(throwing: error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let modelName = task.taskDescription,
              let continuation = downloadContinuations[modelName] else { return }
        
        if let error = error {
            Task { @MainActor in
                self.downloadProgress[modelName] = nil
                self.isDownloading[modelName] = false
                self.downloadContinuations.removeValue(forKey: modelName)
            }
            continuation.resume(throwing: error)
        }
    }
    
    func logAllModelFileSizes() {
        let directory = fileHelper.modelsDirectory
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            let ggufFiles = files.filter { $0.pathExtension == "gguf" }
            for file in ggufFiles {
                let attrs = try FileManager.default.attributesOfItem(atPath: file.path)
                if let fileSize = attrs[.size] as? NSNumber {
                    let sizeMB = Double(fileSize.intValue) / 1024 / 1024
                    print("Model: \(file.lastPathComponent), Size: \(String(format: "%.2f", sizeMB)) MB")
                }
            }
        } catch {
            print("Failed to list model files: \(error)")
        }
    }
}
