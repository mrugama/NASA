//
//  DiskStorage.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/6/24.
//

import Foundation

struct DiskStorage<Value: Codable> {
    private var path: URL?
    private var data: Value? {
        get {
            guard
                let path = path,
                let data = try? Data(contentsOf: path)
            else { return nil }
            let decoder = JSONDecoder()
            return try? decoder.decode(Value.self, from: data)
        }
        set {
            guard let path = path else { return }
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(newValue) else { return }
            try? data.write(to: path)
        }
    }
    
    mutating func save(_ imageID: String, value: Value) {
        path = FileManager
            .directoryPath
            .appendingPathComponent(imageID)
        data = value
    }
    
    mutating func getImageData(_ imageID: String) -> Value? {
        path = FileManager
            .directoryPath
            .appendingPathComponent(imageID)
        return data
    }
    
    func clearCachedDirectory() {
        let path = FileManager.directoryPath
        try? FileManager.default.removeItem(at: path)
    }
}

private extension FileManager {
    static var directoryPath: URL {
        get {
            FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("CachedImages")
        }
        set {}
    }
}
