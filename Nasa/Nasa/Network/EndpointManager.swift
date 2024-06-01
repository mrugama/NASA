//
//  EndpointManager.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

enum EndpointManager {
    case search(query: String)
    case asset(nasaId: String)
    case metadata(nasaId: String)
    case album(name: String)
    
    private var endpoint: String {
        let rootAPI = "https://images-api.nasa.gov"
        switch self {
        case .search(let query):
            return "\(rootAPI)/search?q=\(query)&media_type=image"
        case .asset(let nasaId):
            return "\(rootAPI)/search?q=\(nasaId)&media_type=image"
        case .metadata(let nasaId):
            return "\(rootAPI)/search?q=\(nasaId)&media_type=image"
        case .album(let name):
            return "\(rootAPI)/search?q=\(name)&media_type=image"
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
