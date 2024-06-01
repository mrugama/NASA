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
    func load() async
    @MainActor
    func getImageData(with identifier: String) async throws -> Data
    func item(with id: String) -> Nasa?
    func itemIds() -> [String]
}

class NasaViewModelImpl: NasaViewModel {
    private let dataLoader: DataLoader
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    var nasaItems: [Nasa] = [Nasa]()
    private var page: Int = 1
    private var searchedText: String = ""
    
    @MainActor 
    func search(for text: String) async {
        searchedText = text
        do {
            let search = EndpointManager.search(query: text, page: page, items: 50)
            let searchRequest = try search()
            let response: Response = try await dataLoader.load(request: searchRequest)
            nasaItems = response.collection.items
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    @MainActor
    func load() async {
        page += 1
        do {
            let search = EndpointManager.search(query: searchedText, page: page, items: 50)
            let searchRequest = try search()
            let response: Response = try await dataLoader.load(request: searchRequest)
            nasaItems.append(contentsOf: response.collection.items)
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
