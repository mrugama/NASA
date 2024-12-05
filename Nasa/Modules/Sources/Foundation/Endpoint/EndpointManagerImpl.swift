import Foundation

extension SearchEndpoint.SearchOption {
    func callAsFunction(_ queryItems: inout [URLQueryItem], query: String) {
        switch self {
        case .all:
            return
        default:
            queryItems.append(URLQueryItem(name: self.rawValue, value: query))
        }
    }
}

struct EndpointManagerImpl: EndpointManager {
    private var endpoint: SearchEndpoint
    private var token: String {
        "PASTE-YOUR-API-TOKEN_HERE"
    }
    
    init(_ endpoint: SearchEndpoint) {
        self.endpoint = endpoint
    }
    
    private func makeURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "images-api.nasa.gov"
        var queryItems = [URLQueryItem]()
        
        switch endpoint {
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
        guard let url = makeURL() else { throw EndpointError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
