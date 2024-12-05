import Foundation

public enum AppError: Error {
    case invalidURL
    case noData
    case requestFailed(statusCode: Int)
    case invalidDataType
}

#if DEBUG
public enum FilePath {
    case oneDog
    case fourDogs
    case custom(String)
}
#endif

public protocol DataLoader {
    /// Loads data from url and returns a type that must conform to Decodable
    mutating func load(urlStr: String) async throws -> Data
    /// Loads data from url request and returns a type that must conform to Decodable
    func load<T: Decodable>(urlRequest: URLRequest) async throws -> T
    /// Loads data from url request and returns Data type
    func load(urlRequest: URLRequest) async throws -> Data
    #if DEBUG
    /// Loads data from local and retuns a type that must conform to Decodable
    func load<T: Decodable>(_ path: FilePath) -> T
    #endif
    
    func clearCached() throws
}

public struct NetworkingService {
    /// Provide a factory method to create an instance of DataLoader
    public static func provideDataLoader() -> DataLoader {
        return DataLoaderImpl()
    }
    
    private init() {}
}
