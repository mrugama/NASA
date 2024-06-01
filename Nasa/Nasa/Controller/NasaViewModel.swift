//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

protocol NasaViewModel {
    var nasaItems: [Nasa] { get }
    
    @MainActor 
    func search(for text: String)
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
    func search(for text: String) {
        Task {
            do {
                let search = EndpointManager.search(query: text, page: 1, items: 50)
                let searchRequest = try search()
                let response: Response = try await dataLoader.load(request: searchRequest)
                print(response)
//                nasaItems = response.collection.items
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func item(with id: String) -> Nasa? {
        return nasaItems.first { $0.id == id }
    }
    
    func itemIds() -> [Nasa.ID] {
        return nasaItems.map { $0.id }
    }
}
