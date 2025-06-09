//
//  LLMModelInfo.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import Foundation

struct LLMModelInfo: Identifiable, Decodable {
    let name: String
    let url: URL
    let sizeMB: Int
    let description: String
    let id = UUID()

    private enum CodingKeys: String, CodingKey {
        case name, url, sizeMB, description
    }
}
