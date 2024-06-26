//
//  DataLoader.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

public enum AppError: Error {
    case invalidURL
    case noData
    case requestFailed(statusCode: Int)
    case invalidDataType
}

protocol DataLoader {
    /// Loads data from given URLResquest and returns a type that must conform to Decodable
    func load<T: Decodable>(request: URLRequest) async throws -> T
    /// Loads data from given url and returns Data type
    func load(urlStr: String, storage: DiskStorage<Data>) async throws -> Data
}

struct DataLoaderImpl: DataLoader {
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
    
    func load(urlStr: String, storage: DiskStorage<Data>) async throws -> Data {
        var storage = storage
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
        storage.save(urlStr, value: data)
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
}
