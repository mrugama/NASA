//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import UIKit
import Networking

protocol SearchViewModel {
    typealias Completion = () -> ()
    
    var nasaItems: [NasaViewModel] { get }
    var searchByOptions: [String] { get }
    
    @MainActor
    func search(for text: String, selectedOption: String?, _ completion: @escaping Completion)
    @MainActor
    func loadPrefetchingItems(index: Int, _ completion: @escaping Completion)
    func clearCache()
}

class SearchViewModelImpl: SearchViewModel {
    typealias Option = EndpointManager.SearchOption
    
    private let dataLoader: DataLoader
    private var page: Int = 1
    private var searchedText: String = ""
    private var option: EndpointManager.SearchOption = .all
    private(set) var nasaItems = [NasaViewModel]()
    private(set) var searchByOptions: [String] = Option.allCases.map { $0.capitalized }
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
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
                let response: Response = try await dataLoader.load(urlRequest: searchRequest)
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
                    let response: Response = try await dataLoader.load(urlRequest: searchRequest)
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
    
    func clearCache() {
        try? dataLoader.clearCached()
    }
    
    // MARK: - Helper methods
    
    private func shouldPrefetch(index: Int) -> Bool {
        let prefetchAtIndex = 15
        return (nasaItems.count - prefetchAtIndex) == index
    }
}
