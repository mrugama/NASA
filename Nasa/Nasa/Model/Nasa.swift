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
    let href: String
    let items: [Nasa]
}

struct Nasa: Decodable {
    let href: String
    let data: [NasaInfo]
    let links: [NasaLink]?
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
