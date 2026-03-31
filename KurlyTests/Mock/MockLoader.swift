//
//  MockLoader.swift
//  KurlyTests
//
//  Created by 김승율 on 3/31/26.
//

import Foundation

enum MockLoader {
    static func load<T: Decodable>(_ filename: String) -> T {
        guard let url = Bundle(for: BundleToken.self).url(forResource: filename, withExtension: "json") else {
            fatalError("Mock file \(filename).json not found")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(filename).json")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(filename).json")
        }

        return decoded
    }
}

private final class BundleToken {}
