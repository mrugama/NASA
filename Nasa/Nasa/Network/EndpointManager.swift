//
//  EndpointManager.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

enum EndpointManager {
    case search(query: String, page: Int, items: Int),
         asset(nasaId: String),
         metadata(nasaId: String),
         captions(nasaId: String),
         album(name: String)
    
    private var endpoint: String {
        let rootAPI = "https://images-api.nasa.gov"
        switch self {
        case .search(let query, let page, let items):
            return "\(rootAPI)/search?q=\(query)&media_type=image&page=\(page)&page_size=\(items)"
        case .asset(let nasaId):
            return "\(rootAPI)/asset/\(nasaId)"
        case .metadata(let nasaId):
            return "\(rootAPI)/metadata/\(nasaId)"
        case .captions(let nasaId):
            return "\(rootAPI)/captions/\(nasaId)"
        case .album(let name):
            return "\(rootAPI)/album/\(name)"
        }
    }
    
    func callAsFunction() throws -> URLRequest {
        let token = "PASTE-YOUR-API-TOKEN_HERE"
        guard let url = URL(string: endpoint) else { throw AppError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
