//
//  NasaViewModel.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/4/24.
//

import UIKit
import Networking

class NasaViewModel: Identifiable, Hashable {
    typealias ImageCompletion = (UIImage?) -> ()
    
    let id: String
    let title: String
    let description: String
    let photographer: String
    let location: String
    private let imageURLStr: String?
    private var dataLoader: DataLoader
    
    init(_ nasa: Nasa, dataLoader: DataLoader) {
        id = nasa.nasa_id ?? UUID().uuidString
        title = nasa.title ?? "-"
        description = (nasa.description ?? nasa.description_508 ?? "N/A") ?? "N/A"
        photographer = (nasa.photographer ?? "-") ?? "-"
        location = (nasa.location ?? "-") ?? "-"
        imageURLStr = nasa.href
        self.dataLoader = dataLoader
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NasaViewModel, rhs: NasaViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    @MainActor
    func getImage(_ completion: @escaping ImageCompletion) {
        Task {
            guard
                let urlStr = imageURLStr,
                let data = try? await dataLoader.load(urlStr: urlStr),
                let image = UIImage(data: data)
            else { return }
            completion(image)
        }
    }
}
