import Foundation

public enum EndpointError: Error {
    case invalidURL
}

public enum SearchEndpoint {
    public enum SearchOption: String, CaseIterable {
        case all, title, photographer, location
        public var capitalized: String {
            self.rawValue.capitalized
        }
    }
    
    case search(query: String, page: Int, items: Int, option: SearchOption),
         asset(nasaId: String),
         metadata(nasaId: String),
         captions(nasaId: String),
         album(name: String)
}

public protocol EndpointManager {
    
    init(_ endpoint: SearchEndpoint)
    
    func callAsFunction() throws -> URLRequest
}

public struct EndpointService {
    public init() {}
    public func provideEndpoint(_ option: SearchEndpoint) -> EndpointManager {
        EndpointManagerImpl(option)
    }
}
