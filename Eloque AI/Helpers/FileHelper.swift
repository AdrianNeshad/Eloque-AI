//
//  FileHelper.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import Foundation

struct FileHelper {
    var modelsDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir
    }

    var modelListURL: URL {
        modelsDirectory.appendingPathComponent("ModelList.json")
    }
}
