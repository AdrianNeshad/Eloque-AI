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
                try? fileManager.copyItem(at: bundleURL, to: modelListURL)
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
        let fileManager = FileManager.default
        var models: [LLMModelInfo] = []

        if let data = try? Data(contentsOf: url), !data.isEmpty {
            models = (try? JSONDecoder().decode([LLMModelInfo].self, from: data)) ?? []
        }
        if let bundleURL = Bundle.main.url(forResource: "ModelList", withExtension: "json"),
           let bundleData = try? Data(contentsOf: bundleURL) {
            let bundleModels = (try? JSONDecoder().decode([LLMModelInfo].self, from: bundleData)) ?? []
       
            for bundleModel in bundleModels {
                if !models.contains(where: { $0.name == bundleModel.name }) {
                    models.append(bundleModel)
                }
            }
        }
        DispatchQueue.main.async {
            self.availableModels = models
        }
    }

    func saveAvailableModels() {
        let docs = fileHelper.modelsDirectory
        let url = docs.appendingPathComponent("ModelList.json")
        if let data = try? JSONEncoder().encode(self.availableModels) {
            try? data.write(to: url)
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
        
        // Spara namnet som senaste valda modell
        let modelName = url.deletingPathExtension().lastPathComponent
        lastSelectedModelName = modelName
    }
    
    func isModelDownloaded(_ model: LLMModelInfo) -> Bool {
        let fileURL = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func deleteModel(_ model: LLMModelInfo) throws {
        let fileURL = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
            
            if currentProfile?.sourcePath == fileURL.path {
                self.currentProfile = nil
                self.currentModel = nil
            }
            if lastSelectedModelName == model.name {
                lastSelectedModelName = ""
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
