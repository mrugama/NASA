//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 5/31/24.
//

import Foundation

protocol NasaViewModel {
    var nasaItems: [Nasa] { get }
    
    func item(with id: String) -> Nasa?
    func itemIds() -> [Nasa.ID]
}

class NasaViewModelImpl: NasaViewModel {
    var nasaItems: [Nasa] = [Nasa]()
    
    func item(with id: String) -> Nasa? {
        return nasaItems.first { $0.id == id }
    }
    
    func itemIds() -> [Nasa.ID] {
        return nasaItems.map { $0.id }
    }
}
