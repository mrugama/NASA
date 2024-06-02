//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import UIKit

protocol NasaViewModel {
    typealias Completion = () -> ()
    typealias ImageCompletion = (Result<Data, Error>) -> ()
    var nasaItems: [Nasa] { get }
    
    @MainActor 
    func search(for text: String, _ completion: @escaping Completion)
    @MainActor
    func load(_ completion: @escaping Completion)
    @MainActor
    func getImageData(with identifier: String, _ completion: @escaping ImageCompletion)
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
    func search(for text: String, _ completion: @escaping Completion) {
        searchedText = text
        Task {
            do {
                let search = EndpointManager.search(query: text, page: page, items: 50)
                let searchRequest = try search()
                let response: Response = try await dataLoader.load(request: searchRequest)
                nasaItems = response.collection.items
                completion()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func load(_ completion: @escaping Completion) {
        page += 1
        Task {
            do {
                let search = EndpointManager.search(query: searchedText, page: page, items: 50)
                let searchRequest = try search()
                let response: Response = try await dataLoader.load(request: searchRequest)
                nasaItems.append(contentsOf: response.collection.items)
                completion()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func getImageData(with identifier: String, _ completion: @escaping ImageCompletion) {
        guard
            let nasa = item(with: identifier),
            let urlStr = nasa.href
        else { completion(.failure(AppError.invalidURL)); return }
        Task {
            do {
                let data = try await dataLoader.load(urlStr: urlStr)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func item(with id: String) -> Nasa? {
        return nasaItems.first { $0.nasa_id == id }
    }
    
    func itemIds() -> [String] {
        return nasaItems.map { $0.nasa_id ?? UUID().uuidString }
    }
}
