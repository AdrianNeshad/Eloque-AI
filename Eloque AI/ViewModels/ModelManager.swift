//
//  ModelManager.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import Foundation
import Kuzco

@MainActor
class ModelManager: ObservableObject {
    @Published var availableModels: [LLMModelInfo] = []
    @Published var currentModel: LlamaInstance?
    private var currentProfile: ModelProfile?

    let fileHelper = FileHelper()

    func loadAvailableModels() async throws {
        guard let url = Bundle.main.url(forResource: "ModelList", withExtension: "json") else { return }
        let data = try Data(contentsOf: url)
        availableModels = try JSONDecoder().decode([LLMModelInfo].self, from: data)
    }

    func downloadModel(_ model: LLMModelInfo) async throws -> URL {
        let destination = fileHelper.modelsDirectory.appendingPathComponent("\(model.name).gguf")
        let (data, _) = try await URLSession.shared.data(from: model.url)
        try data.write(to: destination)
        return destination
    }

    func loadModel(at url: URL) async throws {
        let profile = ModelProfile(sourcePath: url.path, architecture: .llamaGeneral)
        currentProfile = profile
        currentModel = await LlamaInstance(
            profile: profile,
            settings: InstanceSettings(),
            predictionConfig: PredictionConfig()
        )
    }

    var currentModelPath: String? {
        currentProfile?.sourcePath
    }
}
