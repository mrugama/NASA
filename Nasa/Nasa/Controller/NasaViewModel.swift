//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import UIKit

protocol NasaViewModel {
    var nasaItems: [Nasa] { get }
    
    @MainActor 
    func search(for text: String) async
    @MainActor
    func getImageData(with identifier: Nasa.ID) async throws -> Data
    func item(with id: String) -> Nasa?
    func itemIds() -> [Nasa.ID]
}

class NasaViewModelImpl: NasaViewModel {
    private let dataLoader: DataLoader
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    var nasaItems: [Nasa] = [Nasa]()
    
    @MainActor 
    func search(for text: String) async {
        do {
            let search = EndpointManager.search(query: text, page: 1, items: 10)
            let searchRequest = try search()
            let response: Response = try await dataLoader.load(request: searchRequest)
            nasaItems = response.collection.items
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    @MainActor
    func getImageData(with identifier: String) async throws -> Data {
        guard
            let nasa = item(with: identifier),
            let urlStr = nasa.href
        else { throw AppError.invalidURL }
        do {
            return try await dataLoader.load(urlStr: urlStr)
        } catch {
            throw error
        }
    }
    
    func item(with id: String) -> Nasa? {
        return nasaItems.first { $0.nasa_id == id }
    }
    
    func itemIds() -> [String] {
        return nasaItems.map { $0.nasa_id ?? UUID().uuidString }
    }
}
