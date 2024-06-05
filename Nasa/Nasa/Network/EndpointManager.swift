//
//  EndpointManager.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

enum EndpointManager {
    enum SearchOption: String, CaseIterable {
        case all, title, photographer, location
        
        func callAsFunction(_ queryItems: inout [URLQueryItem], query: String) {
            switch self {
            case .all:
                return
            case .title:
                queryItems.append(URLQueryItem(name: "title", value: query))
            case .photographer:
                queryItems.append(URLQueryItem(name: "photographer", value: query))
            case .location:
                queryItems.append(URLQueryItem(name: "location", value: query))
            }
        }
        
        var capitalized: String {
            self.rawValue.capitalized
        }
    }
    
    case search(query: String, page: Int, items: Int, option: SearchOption),
         asset(nasaId: String),
         metadata(nasaId: String),
         captions(nasaId: String),
         album(name: String)
    
    private var token: String {
        "PASTE-YOUR-API-TOKEN_HERE"
    }
    
    private func makeURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "images-api.nasa.gov"
        var queryItems = [URLQueryItem]()
        
        switch self {
        case .search(let query, let page, let items, let option):
            components.path = "/search"
            switch option {
            case .all:
                queryItems.append(URLQueryItem(name: "q", value: query))
            default:
                option(&queryItems, query: query)
            }
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            queryItems.append(URLQueryItem(name: "page_size", value: "\(items)"))
        case .asset(let nasaId):
            components.path = "asset/\(nasaId)"
        case .metadata(let nasaId):
            components.path = "metadata/\(nasaId)"
        case .captions(let nasaId):
            components.path = "captions/\(nasaId)"
        case .album(let name):
            components.path = "album/\(name)"
        }
        
        queryItems.append(URLQueryItem(name: "media_type", value: "image"))
        components.queryItems = queryItems
        return components.url
    }
    
    func callAsFunction() throws -> URLRequest {
        guard let url = makeURL() else { throw AppError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
