//
//  Nasa.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

struct Response: Decodable {
    let collection: ResponseDetail
}

struct ResponseDetail: Decodable {
    let version: String
    let items: [Nasa]
}

@dynamicMemberLookup
struct Nasa: Decodable, Hashable, Identifiable {
    var id: String {
        self.nasa_id ?? UUID().uuidString
    }
    let data: [NasaInfo]
    let links: [NasaLink]?
    
    subscript<T>(dynamicMember keyPath: KeyPath<NasaLink, T>) -> T? {
        return links?.first?[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<NasaInfo, T>) -> T? {
        return data.first?[keyPath: keyPath]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Nasa, rhs: Nasa) -> Bool {
        lhs.id == rhs.id
    }
}

struct NasaInfo: Decodable {
    let title: String
    let photographer: String?
    let nasa_id: String
    let description: String?
    let description_508: String?
    var location: String?
}

struct NasaLink: Decodable {
    let href: String
    let rel: String
    let render: String?
}
