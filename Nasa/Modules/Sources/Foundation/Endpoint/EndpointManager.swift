import Foundation

/// Represents errors that can occur when working with endpoints.
public enum EndpointError: Error {
    /// Indicates that the URL is invalid.
    case invalidURL
}

/// Defines the endpoints for searching and fetching resources.
public enum SearchEndpoint {
    /// Options for refining search queries.
    public enum SearchOption: String, CaseIterable {
        /// Search across all fields.
        case all
        /// Search by title.
        case title
        /// Search by photographer.
        case photographer
        /// Search by location.
        case location
        
        /// Returns the capitalized string representation of the search option.
        public var capitalized: String {
            self.rawValue.capitalized
        }
    }
    
    /// Search endpoint with a query, page number, items per page, and search option.
    case search(query: String, page: Int, items: Int, option: SearchOption)
    
    /// Endpoint to fetch details about a specific asset by its NASA ID.
    case asset(nasaId: String)
    
    /// Endpoint to fetch metadata for a specific asset by its NASA ID.
    case metadata(nasaId: String)
    
    /// Endpoint to fetch captions for a specific asset by its NASA ID.
    case captions(nasaId: String)
    
    /// Endpoint to fetch an album by its name.
    case album(name: String)
}

/// A protocol defining the interface for managing and constructing URL requests for endpoints.
public protocol EndpointManager {
    /// Initializes an instance with a specific search endpoint.
    /// - Parameter endpoint: The endpoint to be managed.
    init(_ endpoint: SearchEndpoint)
    
    /// Constructs and returns a URL request for the associated endpoint.
    /// - Throws: `EndpointError.invalidURL` if the URL could not be constructed.
    /// - Returns: A `URLRequest` representing the endpoint.
    func callAsFunction() throws -> URLRequest
}

/// A service that provides endpoint managers for constructing and managing API requests.
public struct EndpointService {
    /// Initializes the endpoint service.
    public init() {}
    
    /// Provides an endpoint manager for the given endpoint.
    /// - Parameter option: The `SearchEndpoint` to manage.
    /// - Returns: An instance of `EndpointManager` capable of managing the given endpoint.
    public func provideEndpoint(_ option: SearchEndpoint) -> EndpointManager {
        EndpointManagerImpl(option)
    }
}
