//
//  DiskStorage.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/6/24.
//

import Foundation

struct DiskStorage {
    var path: URL?
    private var imageData: Data? {
        get {
            guard
                let path = path,
                let data = try? Data(contentsOf: path)
            else { return nil }
            return data
        }
        set {
            guard let path = path else { return }
            try? newValue?.write(to: path)
        }
    }
    
    mutating func save(_ imageID: String, value: Data) {
        path = FileManager
            .directoryPath
            .appendingPathComponent(imageID)
        imageData = value
    }
    
    mutating func getImageData(_ imageID: String) -> Data? {
        path = FileManager
            .directoryPath
            .appendingPathComponent(imageID)
        return imageData
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
