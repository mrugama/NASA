//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import UIKit

enum SearchFilter: String, CaseIterable {
    case title, photographer, location
}

protocol SearchViewModel {
    typealias Completion = () -> ()
    typealias ImageCompletion = (Result<Data, Error>) -> ()
    
    var nasaItems: [NasaViewModel] { get }
    var searchByOptions: [String] { get }
    
    @MainActor
    func search(for text: String, selectedOption: String?, _ completion: @escaping Completion)
    @MainActor
    func loadPrefetchingItems(index: Int, _ completion: @escaping Completion)
}

class SearchViewModelImpl: SearchViewModel {
    typealias Option = EndpointManager.SearchOption
    
    private let dataLoader: DataLoader
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    var nasaItems = [NasaViewModel]()
    var searchByOptions: [String] = Option.allCases.map { $0.capitalized }
    private var page: Int = 1
    private var searchedText: String = ""
    private var option: EndpointManager.SearchOption = .all
    
    @MainActor 
    func search(for text: String, selectedOption: String?, _ completion: @escaping Completion) {
        searchedText = text
        if let selectedOptionStr = selectedOption, 
            let selectedOption = Option(rawValue: selectedOptionStr.lowercased()) {
            self.option = selectedOption
        }
        Task {
            do {
                let search = EndpointManager.search(query: text, page: page, items: 50, option: option)
                let searchRequest = try search()
                let response: Response = try await dataLoader.load(request: searchRequest)
                nasaItems = response.collection.items.map{ NasaViewModel($0, dataLoader: dataLoader) }
                completion()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func loadPrefetchingItems(index: Int, _ completion: @escaping Completion) {
        if shouldPrefetch(index: index) {
            page += 1
            Task {
                do {
                    let search = EndpointManager.search(query: searchedText, page: page, items: 50, option: option)
                    let searchRequest = try search()
                    let response: Response = try await dataLoader.load(request: searchRequest)
                    nasaItems.append(
                        contentsOf: response.collection.items.map{ NasaViewModel($0, dataLoader: dataLoader) }
                    )
                    completion()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    @MainActor
    func getImageData(with nasa: Nasa, _ completion: @escaping ImageCompletion) {
        guard
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
    
    // MARK: - Helper methods
    
    private func shouldPrefetch(index: Int) -> Bool {
        let prefetchAtIndex = 15
        return (nasaItems.count - prefetchAtIndex) == index
    }
}
