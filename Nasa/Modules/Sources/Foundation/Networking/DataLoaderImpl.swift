//
//  File.swift
//  
//
//  Created by Marlon Rugama on 4/27/24.
//

import Foundation

internal struct DataLoaderImpl: DataLoader {
    
    private var storage = DiskStorageImpl<Data>()
    
    // This implementation is private and cannot be accessed from outside the Swift Package
    func load<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        do {
            try handleResponse(response)
        } catch {
            throw error
        }
        
        guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            throw AppError.invalidDataType
        }
        
        return decodedData
    }
    
    mutating func load(urlStr: String) async throws -> Data {
        if let cacheData = storage.getImageData(urlStr) {
            return cacheData
        }
        guard let url = URL(string: urlStr) else { throw AppError.invalidURL }
        
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.requestFailed(statusCode: 0)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    func load<T: Decodable>(urlRequest: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.requestFailed(statusCode: 0)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            throw AppError.invalidDataType
        }
        
        return decodedData
    }
    
    func load(urlRequest: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.requestFailed(statusCode: 0)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    private func handleResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.requestFailed(statusCode: 0)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
    
    #if DEBUG
    func load<T: Decodable>(_ path: FilePath) -> T {
        let data: Data
        do {
            data = try Data(contentsOf: path.url)
        } catch {
            fatalError("Couldn't load \(path.url) from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(path.url) as \(T.self):\n\(error)")
        }
    }
    #endif
    
    func clearCached() throws {
        try storage.clearCachedDirectory()
    }
}

#if DEBUG
extension FilePath {
    var url: URL {
        switch self {
        case .oneDog:
            return getFileUrl(with: "OwnerOnePetResponse.json")
        case .fourDogs:
            return getFileUrl(with: "OwnerFourPetsResponse.json")
        case .custom(let path):
            return getFileUrl(with: path)
        }
    }
    
    private func getFileUrl(with str: String) -> URL {
        guard let file = Bundle.main.url(forResource: str, withExtension: nil)
            else {
                fatalError("Couldn't find \(str) in main bundle.")
        }
        return file
    }
}
#endif
