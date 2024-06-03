//
//  SearchCollectionViewCellRegistration.swift
//  Nasa
//
//  Created by Marlon Rugama on 6/3/24.
//

import UIKit

@MainActor
extension UICollectionView.CellRegistration<SearchCollectionViewCell, Nasa> {
    init(_ viewModel: SearchViewModel) {
        self.init { searchCell, indexPath, nasa in
            if let nasaId = nasa.nasa_id {
                viewModel.getImageData(with: nasaId) { result in
                    switch result {
                    case .success(let data):
                        let image = UIImage(data: data)
                        searchCell.configure(with: image)
                    case .failure:
                        return
                    }
                }
            }
        }
    }
}
