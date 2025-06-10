//
//  LLMModelInfo.swift
//  Eloque AI
//
//  Created by Adrian Neshad on 2025-06-09.
//

import Foundation

struct LLMModelInfo: Identifiable, Decodable {
    let name: String
    let url: URL
    let sizeMB: Int
    let description: String
    let compatibility: String
    let id = UUID()

    private enum CodingKeys: String, CodingKey {
        case name, url, sizeMB, description, compatibility
    }
    
    var compatibleDevices: [String] {
        compatibility.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    func systemIconName(for device: String) -> String? {
        switch device.lowercased() {
        case "mac": return "macbook"
        case "ipad": return "ipad.landscape"
        case "iphone": return "iphone"
        default: return nil
        }
    }
}
