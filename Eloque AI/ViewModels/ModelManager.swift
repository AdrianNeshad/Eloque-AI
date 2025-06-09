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
    @Published var availableModels: [LLMModelInfo] = []
    @Published var currentModel: LlamaInstance?
    @Published var downloadProgress: [String: Double] = [:]
    
    private var currentProfile: ModelProfile?
    let fileHelper = FileHelper()

    // URLSession med delegat för progress
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    // Ladda tillgängliga modeller från JSON
    func loadAvailableModels() async throws {
        guard let url = Bundle.main.url(forResource: "ModelList", withExtension: "json") else { return }
        let data = try Data(contentsOf: url)
        let models = try JSONDecoder().decode([LLMModelInfo].self, from: data)
        DispatchQueue.main.async {
            self.availableModels = models
        }
    }

    // Nedladdning med progress och async/await via continuation
    func downloadModel(_ model: LLMModelInfo) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let downloadTask = session.downloadTask(with: model.url) { [weak self] localURL, _, error in
                guard let self = self else { return }
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let localURL = localURL else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                do {
                    let destination = self.fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }
                    try FileManager.default.moveItem(at: localURL, to: destination)
                    DispatchQueue.main.async {
                        self.downloadProgress[model.name] = nil
                    }
                    continuation.resume(returning: destination)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            downloadTask.taskDescription = model.name
            downloadTask.resume()
            DispatchQueue.main.async {
                self.downloadProgress[model.name] = 0.0
            }
        }
    }

    // Ladda modellen i minnet (async, trådsäker)
    func loadModel(at url: URL) async throws {
        let profile = ModelProfile(sourcePath: url.path, architecture: .llamaGeneral)
        DispatchQueue.main.async {
            self.currentProfile = profile
        }
        let instance = await LlamaInstance(
            profile: profile,
            settings: InstanceSettings(),
            predictionConfig: PredictionConfig()
        )
        DispatchQueue.main.async {
            self.currentModel = instance
        }
    }
    
    // Kontrollera om modellen är nedladdad (finns på disk)
    func isModelDownloaded(_ model: LLMModelInfo) -> Bool {
        let fileURL = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    // Radera nedladdad modell
    func deleteModel(_ model: LLMModelInfo) throws {
        let fileURL = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
            if currentProfile?.sourcePath == fileURL.path {
                DispatchQueue.main.async {
                    self.currentProfile = nil
                    self.currentModel = nil
                }
            }
        }
    }
    
    // Kontrollera om en modell är vald som aktiv
    func isModelSelected(_ model: LLMModelInfo) -> Bool {
        currentModelPath == fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf").path
    }

    var currentModelPath: String? {
        currentProfile?.sourcePath
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard let modelName = downloadTask.taskDescription else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.downloadProgress[modelName] = progress
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let modelName = downloadTask.taskDescription else { return }
        DispatchQueue.main.async {
            self.downloadProgress[modelName] = nil
        }
    }
}
