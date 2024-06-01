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
struct Nasa: Decodable {    
    let data: [NasaInfo]
    let links: [NasaLink]?
    
    subscript<T>(dynamicMember keyPath: KeyPath<NasaLink, T>) -> T? {
        guard let item = links?.first else { return nil }
        return item[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<NasaInfo, T>) -> T? {
        guard let item = data.first else { return nil }
        return item[keyPath: keyPath]
    }
}

struct NasaInfo: Decodable {
    let title: String
    let nasa_id: String
    let description: String?
}

struct NasaLink: Decodable {
    let href: String
    let rel: String
    let render: String?
}
